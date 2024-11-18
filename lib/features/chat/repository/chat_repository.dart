// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chatting_app/Common/Providers/messsage_reply_provider.dart';
import 'package:chatting_app/Common/Repository/commonFirebase.dart';
import 'package:chatting_app/Common/enums/message_enmu.dart';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:chatting_app/features/Group/model/group_model.dart';
import 'package:chatting_app/features/chat/model/chat_contact.dart';
import 'package:chatting_app/features/chat/model/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:uuid/uuid.dart';

final chatrepository = Provider((ref) => ChatRepository(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  void SendTextMessage(
      {required BuildContext context,
      required String text,
      required String receiverUserId,
      required UserProfile senderUser,
      required MessageReply? messagereply}) async {
    print("text msg repo");
    //users->sender_user_id->receiver_user_id->messages->message_id->store messages
    try {
      var timeSent = DateTime.now();
      UserProfile receiverUserData;
      var user = await firestore.collection("users").doc(receiverUserId).get();
      ////////////////////////////////////
      addFriend(receiverUserId);
/////////////////////////////////////////
      receiverUserData = UserProfile.fromJson(user.data()!);
      print("text msg repo _saveDataToContactSubCollection");
      var messageid = const Uuid().v1();
      _saveDataToContactSubCollection(
          senderUser, receiverUserData, text, timeSent, receiverUserId);

      ////////////////////////////////
      receiverUserData = UserProfile.fromJson(user.data()!);
      print("text msg repo _savemessageSubcollection");
      _savemessageSubcollection(
        receiverId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageid,
        senderId: senderUser.uid,
        messagereply: messagereply,
        receiverusername: receiverUserData.firstName,
        senderusername: senderUser.firstName,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void _saveDataToContactSubCollection(
    UserProfile senderuserdata,
    UserProfile receiveruserdata,
    String text,
    DateTime time,
    String recieverUserId,
  ) async {
    var receiverside = ChatContact(
        name: senderuserdata.firstName,
        profilepic: senderuserdata.profile,
        contactId: senderuserdata.uid,
        timetosent: time,
        lastmessage: text);

    await firestore
        .collection("users")
        .doc(recieverUserId)
        .collection("chats")
        .doc(senderuserdata.uid)
        .set(receiverside.toMap());
    var senderside = ChatContact(
        name: receiveruserdata.firstName,
        profilepic: receiveruserdata.profile,
        contactId: receiveruserdata.uid,
        timetosent: time,
        lastmessage: text);
    await firestore
        .collection("users")
        .doc(senderuserdata.uid)
        .collection("chats")
        .doc(receiveruserdata.uid)
        .set(senderside.toMap());
  }

  void _savemessageSubcollection({
    required String senderId,
    required String receiverId,
    required String text,
    required DateTime timeSent,
    required MessageEnum messageType, // Assuming MessageEnum is defined
    required String messageId,
    required MessageReply? messagereply,
    required String senderusername,
    required String receiverusername,
  }) async {
    final DateTime now = DateTime.now(); // Current timestamp
    final String dateId = DateFormat('yyyy_MM_dd')
        .format(now); // Generate the date-based document ID

    DocumentReference dayChatRef = FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(receiverId)
        .collection('chats')
        .doc(dateId);
    ///////////////////////////////////////////////

    /////////////// starting adding the user in the friends list/////////////
    addFriend(senderId);
    ///////////////ending adding the user in the friends list/////////////
    DocumentReference receiversideRef = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('friends')
        .doc(senderId)
        .collection('chats')
        .doc(dateId);

    try {
      // Create the new message object
      final message = MESSAGES(
          senderId: senderId,
          receiverId: receiverId,
          text: text,
          timeSent: timeSent,
          type: messageType,
          messageId: messageId,
          isSeen: false,
          repliedMessage: messagereply == null ? "" : messagereply.message,
          repliedTo: messagereply == null
              ? ""
              : messagereply.isMe
                  ? senderusername
                  : receiverusername,
          repliedMessageType: messagereply == null
              ? MessageEnum.text
              : messagereply.messageEnum);

      // Get the current day's document to check if it exists
      DocumentSnapshot dayChatDoc = await dayChatRef.get();

      if (dayChatDoc.exists) {
        // If the document exists, append the new message to the 'messages' array
        await dayChatRef.update({
          'messages': FieldValue.arrayUnion([message.toMap()]),
        });
        await receiversideRef.update({
          'messages': FieldValue.arrayUnion([message.toMap()]),
        });
      } else {
        // If the document doesn't exist, create new documents with the message
        day_chats newDayChat = day_chats(
          date: now, // Use the current date for the new chat
          isvanish: false, // Default value for isvanish
          messages: [message], // Start with the new message
        );

        day_chats newReceiverChat = day_chats(
          date: now,
          isvanish: false,
          messages: [message],
        );

        await dayChatRef.set(newDayChat.toMap());
        await receiversideRef.set(newReceiverChat.toMap());
      }
    } catch (e) {}
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Stream<List<ChatContact>> getChatContacts(bool lock) async* {
    // Listen to the stream of excluded contact IDs (groupIds)
    await for (var excludedContactIds in getUserState()) {
      // print("excludedContactIds==$excludedContactIds");
      yield* firestore
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("chats")
          .snapshots()
          .asyncMap((snapshot) async {
        List<ChatContact> contacts = [];

        for (var document in snapshot.docs) {
          var chatContact = ChatContact.fromMap(document.data());

          // Exclude contacts who are in the excludedContactIds list
          if (!lock) {
            // print("if block execute means unlock users");
            if (!excludedContactIds.contains(chatContact.contactId)) {
              var userData = await firestore
                  .collection("users")
                  .doc(chatContact.contactId)
                  .get();
              var user = UserProfile.fromMap(userData.data()!);
              contacts.add(ChatContact(
                name: user.firstName,
                profilepic: user.profile,
                timetosent: chatContact.timetosent,
                contactId: chatContact.contactId,
                lastmessage: chatContact.lastmessage,
              ));
            }
          } else {
            // print("else block execute means lock users");
            if (excludedContactIds.contains(chatContact.contactId)) {
              var userData = await firestore
                  .collection("users")
                  .doc(chatContact.contactId)
                  .get();
              var user = UserProfile.fromMap(userData.data()!);
              contacts.add(ChatContact(
                name: user.firstName,
                profilepic: user.profile,
                timetosent: chatContact.timetosent,
                contactId: chatContact.contactId,
                lastmessage: chatContact.lastmessage,
              ));
            }
          }
        }
        // print("contacts all +${contacts}");

        return contacts; // Return the filtered contacts list
      });
    }
  }

  /////////////////////////////////////////////////////////////////////////////////

  Stream<List<Map<String, dynamic>>> getDayChats(String receiverId) {
    print("getDayChats");
    return FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("friends")
        .doc(receiverId)
        .collection("chats")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() ?? {};

        // Return the document data, which should include 'messages' and any other relevant fields
        return {
          ...data,
          // Ensure messages is a List; if it's not, default to an empty list
          'messages': data['messages'] is List ? data['messages'] : [],
        };
      }).toList();
    });
  }

  void sendfileMessages({
    required BuildContext context,
    required File file,
    required String receiveruserid,
    required UserProfile senderuserdata,
    required ProviderRef ref,
    required MessageEnum type,
    required MessageReply? messagereply,
  }) async {
    print("repo chat file");
    var timesent = DateTime.now();
    var messageid = const Uuid().v1();
    String imageUrl = await ref
        .read(commonFirebaseStorageRepositoryProvider)
        .storeFileToFirebase(
          "chat/${type.type}/${senderuserdata.uid}/$receiveruserid/$messageid",
          file,
        );
    UserProfile receiveruserdata;
    var userdata =
        await firestore.collection("users").doc(receiveruserid).get();
    receiveruserdata = UserProfile.fromMap(userdata.data()!);
    String contactmsg;
    switch (type) {
      case MessageEnum.image:
        contactmsg = "photo";
        break;
      case MessageEnum.video:
        contactmsg = "video";
        break;
      case MessageEnum.audio:
        contactmsg = "audio";
        break;
      case MessageEnum.gif:
        contactmsg = "gif";
        break;
      default:
        contactmsg = "text";
    }

    try {
      ////////////////////////////////////
      addFriend(receiveruserid);
/////////////////////////////////////////
      _saveDataToContactSubCollection(senderuserdata, receiveruserdata,
          contactmsg, timesent, receiveruserid);
      _savemessageSubcollection(
        senderId: senderuserdata.uid,
        receiverId: receiveruserid,
        text: imageUrl,
        timeSent: timesent,
        messageType: type,
        messageId: messageid,
        messagereply: messagereply,
        receiverusername: receiveruserdata.firstName,
        senderusername: senderuserdata.firstName,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Stream<List<String>> getUserState() async* {
    try {
      // Listen to real-time updates of the user document using snapshots()
      Stream<DocumentSnapshot<Map<String, dynamic>>> userStream =
          firestore.collection("users").doc(auth.currentUser!.uid).snapshots();

      List<String> previousGroupId = [];

      await for (var docSnapshot in userStream) {
        if (docSnapshot.exists) {
          // Access the 'groupId' attribute safely and cast to List<String>
          List<String> groupId = List<String>.from(
              docSnapshot.data()?['lockSettings']['users'] ?? []);

          // Print Group ID

          // Yield the result only if the groupId has changed to avoid unnecessary renders
          if (groupId != previousGroupId) {
            yield groupId;
            previousGroupId = groupId;
          }
        } else {
          // print("User document does not exist.");
          yield []; // Yield an empty list if document doesn't exist
        }
      }
    } catch (e) {
      // print("Error retrieving user state: $e");
      yield []; // Yield an empty list in case of error
    }
  }

//////////////////////////////////////////////////////////////////////////////////
  ///
  Future<void> setSeen(
      BuildContext context, String receiverId, String messageId) async {
    // print("is setseen function");
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Reference to the chats collection for the specific friend
      final chatsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(receiverId)
          .collection('chats');

      // Retrieve all documents in the chats collection (each document represents a date)
      final snapshot = await chatsCollection.get();

      // Iterate through each date document
      for (var dateDoc in snapshot.docs) {
        Map<String, dynamic> messages = dateDoc['messages']; // Change to Map
        // print("messages ${messages}");
        // Iterate through the map to find the messageId
        for (var key in messages.keys) {
          //logger.w("key @@@@@@@@@@@@@@@@@@@@@${key}");
          if (messages[key]['messageId'] == messageId) {
            // Update only the isSeen field of the specific message
            await dateDoc.reference.update({
              'messages.$key.isSeen': true, // Update isSeen field
            });

            // print('Message seen status updated successfully.');
            return;
          }
        }
      }

      // print('Message with ID $messageId not found.');
    } catch (e) {
      // print('Error updating message seen status: $e');
    }
  }

///////////////////////// GROUPS CHARTS///////////
  ///
  Stream<List<Group>> getChatGroups() {
    return firestore.collection('groups').snapshots().map((event) {
      List<Group> groups = [];
      for (var document in event.docs) {
        var group = Group.fromMap(document.data());
        if (group.membersUid.contains(auth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  Stream<List<MESSAGES>> getChatStream(String recieverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<MESSAGES> messages = [];
      for (var document in event.docs) {
        messages.add(MESSAGES.fromMap(document.data()));
      }
      return messages;
    });
  }

  Stream<List<MESSAGES>> getGroupChatStream(String groudId) {
    return firestore
        .collection('groups')
        .doc(groudId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<MESSAGES> messages = [];
      for (var document in event.docs) {
        messages.add(MESSAGES.fromMap(document.data()));
      }
      return messages;
    });
  }

  ////////////////////////////////////////////GROUPS//////////////////////////

  Future<void> addFriend(String uid) async {
    // Get the current user's UID (the user who is making the request)
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Reference to the current user document
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);

      // Reference to the target user document (the one to be added to the friends list)
      DocumentReference targetUserRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      // Check if the target user exists
      DocumentSnapshot targetUserSnapshot = await targetUserRef.get();

      if (targetUserSnapshot.exists) {
        // Get the current friend's list
        DocumentSnapshot currentUserSnapshot = await currentUserRef.get();
        List<dynamic> friendsList = currentUserSnapshot.get('friends') ?? [];

        // Check if the uid is already in the friends list
        if (!friendsList.contains(uid)) {
          // Add the uid to the current user's friends list
          friendsList.add(uid);

          // Update the current user's document with the new friends list
          await currentUserRef.update({
            'friends': friendsList,
          });
          print('Friend added successfully!');
        } else {
          print('UID already in friends list.');
        }
      } else {
        print('Target user does not exist.');
      }
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

/////////////////////////////////////////////////////////
  Future<void> updatedonline(String receiverId, bool status) async {
    try {
      print("updatedonline repository");
      // Get current user ID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Update all friends' online status to false
      CollectionReference friendsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends');

      // Fetch all friends documents
      QuerySnapshot friendsSnapshot = await friendsCollection.get();
      print("friendsSnapshot${friendsSnapshot}");
      // Set isonline to false for each friend
      for (var friendDoc in friendsSnapshot.docs) {
        await friendDoc.reference.update({
          'isonline': status,
        });
      }
      print("All friends' online status updated to false successfully.");
    } catch (e) {
      print("Error updating online status: $e");
    }
  }
}

Future<void> updateChatIsVanish(
    String loginid, String receiverid, String date, bool status) async {
  try {
    // Get the current user's ID

    // Reference to the specific chat document
    await FirebaseFirestore.instance
        .collection('users')
        .doc(loginid)
        .collection('friends')
        .doc(receiverid) // Use the correct receiverId for friend document
        .collection('chats')
        .doc(
            date) // Use chatDate passed to the function to refer to the specific chat
        .update({'isvanish': status});

    //print('Document updated successfully.');
  } catch (e) {
    //print('Error updating document: $e');
  }
}
