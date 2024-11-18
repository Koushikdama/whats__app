import 'dart:io';

import 'package:chatting_app/Common/Providers/messsage_reply_provider.dart';
import 'package:chatting_app/Common/Repository/commonFirebase.dart';
import 'package:chatting_app/Common/enums/message_enmu.dart';
import 'package:chatting_app/Common/utils/functions.dart';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';

import 'package:chatting_app/features/Status/Common/get_coordinate.dart';
import 'package:chatting_app/features/Status/Model/status_model.dart';
import 'package:chatting_app/features/chat/controller/chat_controller.dart';
import 'package:chatting_app/features/chat/repository/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final statusRepositoryProvider = Provider(
  (ref) => StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);
final statusRepository2 = Provider((ref) {
  final chatrepo = ref.watch(chatrepository);
  return ChatController(chatrepository: chatrepo, ref: ref);
});

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;
  StatusRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void uploadStatus(
      {required String username,
      required String profilePic,
      required String phoneNumber,
      required File statusImage,
      required BuildContext context,
      required String caption,
      required List<String> tagusers}) async {
    try {
      removeOldStatuses();
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;

      // Upload the image and get its URL
      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            '/status/$statusId$uid',
            statusImage,
          );

      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      // Gather a list of user IDs who can see the status
      List<String> uidWhoCanSee = [];

      // Uncomment if needed: Populate `uidWhoCanSee` based on contacts in Firestore
      // for (int i = 0; i < contacts.length; i++) {
      //   var userDataFirebase = await firestore
      //       .collection('users')
      //       .where(
      //         'phoneNumber',
      //         isEqualTo:
      //             contacts[i].phones[0].number.replaceAll(RegExp(r'\D'), ''),
      //       )
      //       .get();

      //   if (userDataFirebase.docs.isNotEmpty) {
      //     var userData = UserProfile.fromMap(userDataFirebase.docs[0].data());
      //     uidWhoCanSee.add(userData.uid);
      //   }
      // }

      // Adding friends from NearbyUserService to `uidWhoCanSee`
      var uids =
          await NearbyUserService().getUsersInBothFriendsAndContacts(uid);
      if (uids is List<String>) {
        uidWhoCanSee.addAll(uids);
      }
      print("mediaurl${imageUrl} == ${caption}");
      // Prepare the media object
      Media newMedia = Media(
        mediaUrl: imageUrl,
        mediaType: 'image', // or 'video' based on file type
        viewers: [],
        replies: [],
        caption: caption, // Add caption functionality as needed
        uploadAt: DateTime.now(),
      );

      // Fetch the user's status document
      var statusDocSnapshot =
          await firestore.collection('status').doc(uid).get();
      print("statusDocSnapshot");
      var teststatusDocSnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('status')
          .doc(uid)
          .get();

      print("teststatusDocSnapshot ${teststatusDocSnapshot.exists}");
      if (teststatusDocSnapshot.exists) {
        print("testing if ");
        // Existing status found, update it with new media
        Status status = Status.fromMap(statusDocSnapshot.data()!);
        status.media
            .add(newMedia); // Append the new media to the existing media list

        await firestore.collection('status').doc(uid).update({
          'media': status.media.map((mediaItem) => mediaItem.toMap()).toList(),
        });
        await firestore
            .collection('users')
            .doc(uid)
            .collection('status')
            .doc(uid)
            .set(status.toMap());
        print("testing if successfil");
      }
      if (statusDocSnapshot.exists) {
        // Existing status found, update it with new media
        Status status = Status.fromMap(statusDocSnapshot.data()!);
        status.media
            .add(newMedia); // Append the new media to the existing media list

        await firestore.collection('status').doc(uid).update({
          'media': status.media.map((mediaItem) => mediaItem.toMap()).toList(),
        });
        print("taguserstaguserstaguserstaguserstagusers${tagusers}");
        if (tagusers.isNotEmpty) {
          print("id if");
          for (String user in tagusers) {
            // ref
            //     .read(chatcontroller)
            //     .sendMessage(context, "STATUS POSTED", user);
            final chatrepo = ref.watch(chatrepository);

            chatrepo.SendTextMessage(
                context: context,
                text: "POSTED STATUS",
                receiverUserId: user,
                senderUser: await getUserProfile(uid),
                messagereply: MessageReply(
                    "{-S-T-A-T-U-S-}${statusId}{-I-M-G-}",
                    true,
                    MessageEnum.text));
          }
        }

        print("Status updated");
      } else {
        // No existing status, create a new one
        Status status = Status(
          uid: uid,
          username: username,
          phoneNumber: phoneNumber,
          media: [newMedia], // Initialize with a list containing the new media
          createdAt: DateTime.now(),
          profilePic: profilePic,
          statusId: statusId,
          whoCanSee: uidWhoCanSee,
        );
        if (tagusers.isNotEmpty) {
          print("else if");
          for (String user in tagusers) {
            final chatrepo = ref.watch(chatrepository);

            chatrepo.SendTextMessage(
                context: context,
                text: "POSTED STATUS",
                receiverUserId: user,
                senderUser: await getUserProfile(uid),
                messagereply: MessageReply(
                    "{-S-T-A-T-U-S-}${statusId}{-I-M-G-}",
                    true,
                    MessageEnum.text));
          }
        }
        await firestore.collection('status').doc(uid).set(status.toMap());
        await firestore
            .collection('users')
            .doc(uid)
            .collection("status")
            .doc(uid)
            .set(status.toMap());
        print("New status created");
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      showSnackBar(context, 'Error uploading status: ${e.toString()}');
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    removeOldStatuses();
    print("repository status ${FirebaseAuth.instance.currentUser!.uid}");

    try {
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      } else {
        showSnackBar(context, 'Permission to access contacts denied.');
        return statusData; // Return an empty list if permission is denied
      }

      // Process contact numbers
      List<String> formattedNumbers =
          contacts.where((contact) => contact.phones.isNotEmpty).map((contact) {
        String formattedNumber =
            contact.phones[0].number.replaceAll(RegExp(r'\D'), '');
        return formattedNumber.length > 10
            ? formattedNumber.substring(formattedNumber.length - 10)
            : formattedNumber;
      }).toList();
      print("formattedNumbers: $formattedNumbers");

      // Fetch all status documents
      var statusesSnapshot =
          await FirebaseFirestore.instance.collection('status').get();

      for (var doc in statusesSnapshot.docs) {
        Map<String, dynamic> tempData = doc.data();

        // Extract the whoCanSee list and postedId for each status
        List<dynamic> whoCanSee = tempData["whoCanSee"] ?? [];
        String postedId = tempData["uid"] ?? '';

        var uids = await NearbyUserService().getUsersInBothFriendsAndContacts(
            FirebaseAuth.instance.currentUser!.uid);

        // Check if current user ID is in whoCanSee and if poster is a contact
        if (whoCanSee.contains(FirebaseAuth.instance.currentUser?.uid) &&
            uids.contains(postedId)) {
          Status tempStatus = Status.fromMap(tempData);

          // Check if current user is in whoCanSee and add to statusData
          if (tempStatus.whoCanSee
              .contains(FirebaseAuth.instance.currentUser?.uid)) {
            tempStatus.username =
                await getnamefromphone(tempStatus.phoneNumber);
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching statuses: $e');
      }
      showSnackBar(context, 'Error fetching statuses: ${e.toString()}');
      print(e.toString());
    }
    print("statusData: $statusData");

    return statusData;
  }

  Future<void> addViewerToMedia({
    required int mediaIndex,
    required String userId,
  }) async {
    print("repository ++++++++ Media Index: $mediaIndex nice ${userId}");

    // Reference to the specific status document
    final statusDocRef =
        FirebaseFirestore.instance.collection('status').doc(userId);

    // Transaction to ensure data consistency
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(statusDocRef);

      if (!snapshot.exists) {
        throw Exception('Status not found');
      }

      // Retrieve current media list
      List<dynamic> mediaList = snapshot.data()?['media'] ?? [];
      print("mediaList.length${mediaList.length}");
      // Validate media list and index
      if (mediaList.isEmpty ||
          mediaIndex < 0 ||
          mediaIndex >= mediaList.length) {
        throw Exception('Invalid media index or media list is empty.');
      }

      // Check if media item at the specified index has a 'viewers' field
      Map<String, dynamic> mediaItem = mediaList[mediaIndex];
      if (!mediaItem.containsKey('viewers')) {
        mediaItem['viewers'] = [];
      }
      List<dynamic> viewersList = mediaItem['viewers'] as List<dynamic>;

      print("Existing viewersList: $viewersList");

      // Fetch the user profile using the userId
      final userProfileSnapshot = await FirebaseFirestore.instance
          .collection(
              'users') // Assuming user profiles are stored in the 'users' collection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!userProfileSnapshot.exists) {
        throw Exception('User profile not found');
      }

      // Assuming UserProfile model has a constructor that accepts a map of fields
      var userProfile = UserProfile.fromMap(userProfileSnapshot.data()!);

      // Check if the user is already in the viewers list
      bool userExists = viewersList.any((viewer) => viewer['id'] == userId);
      print("User exists: $userExists");

      if (!userExists && userId != FirebaseAuth.instance.currentUser!.uid) {
        print("Adding user to viewers list");

        // Add new viewer details
        viewersList.add({
          'username': await getnamefromphone(userProfile.phoneNumber),
          'viewedAt': DateTime.now().toIso8601String(),
          "id": userId,
          "profile": userProfile.profile
        });

        // Update the viewers list in the media item
        mediaList[mediaIndex]['viewers'] = viewersList;

        print("Updated mediaList: $mediaList");

        // Update the media field in Firestore
        transaction.update(statusDocRef, {'media': mediaList});
      }
    });
  }
}
