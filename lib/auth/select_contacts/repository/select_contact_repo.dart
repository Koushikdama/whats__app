import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:chatting_app/auth/select_contacts/Model/contact_users.dart';
import 'package:chatting_app/features/chat/screens/mobile_chat_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectContactsRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({
    required this.firestore,
  });
  Stream<List<Contacts>> getContactsStream() async* {
    List<Contact> contacts = [];
    List<Contacts> contactses = [];
    bool isPrivate = false;
    Map<String, dynamic> users = {};
    List<Contacts> privateContacts = [];
    List<Contacts> usersNot = [];

    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);

        var privateIs =
            await getUserAttribute("isactivatePrivate").then((attributeValue) {
          isPrivate = attributeValue ?? false; // Set default to false if null
          return attributeValue;
        });

        users = await getUserAttribute("lockSettings").then((attributeValue) {
          users = attributeValue ?? {}; // Set default to an empty map if null
          return attributeValue;
        });

        for (Contact contact in contacts) {
          print("contact number ${contact.phones[0].toString()}");
          var data = await getUserByPhoneNumber(contact.phones[0].toString());
          print("data!.firstName: ${data?.firstName}");

          String formattedNumber =
              contact.phones[0].toString().replaceAll(RegExp(r'\D'), '');
          formattedNumber = formattedNumber.length > 10
              ? formattedNumber.substring(formattedNumber.length - 10)
              : formattedNumber;

          if (data?.firstName == null) {
            usersNot.add(Contacts(
                name: contact.displayName,
                description: "",
                profilepic:
                    'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                phonenumber: formattedNumber,
                uid: "NOT"));
          }

          if ((users['users'] as List).contains(data?.uid)) {
            print("id executed ${contact.displayName}");
            privateContacts.add(Contacts(
                name: contact.displayName,
                description: data!.describes.descriptio,
                phonenumber: data.phoneNumber,
                profilepic: data.profile,
                uid: data?.uid ?? ""));
          } else {
            print("id executed ${contact.displayName}");
            contactses.add(Contacts(
                name: contact.displayName,
                description: data!.describes.descriptio,
                phonenumber: data.phoneNumber,
                profilepic: data.profile,
                uid: data.uid));
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    // Yield the final list based on isPrivate
    yield isPrivate ? privateContacts : [...contactses, ...usersNot];
  }

  void selectContact(Contacts selectedContact, BuildContext context) async {
    print("repository select contact");
    try {
      print("try selectContact${selectedContact.phonenumber}");
      var userCollection = await firestore.collection('users').get();

      // print("usercollection$userCollection");
      bool isFound = false;

      for (var document in userCollection.docs) {
        print("documents selectContact ${document.data()}");
        // var userData = UserProfile.fromMap(document.data());

        NearbyCoordinates near = NearbyCoordinates(
            nearby: document["nearbyCoordinates"]["nearby"],
            latitude: document["nearbyCoordinates"]["latitude"],
            longitude: document["nearbyCoordinates"]["longitude"],
            radius: document["nearbyCoordinates"]["radius"]);
        Description dse = Description(
            descriptio: document["describes"]["descriptio"],
            dateTime: DateTime.fromMillisecondsSinceEpoch(
                (document["describes"]["dateTime"])));
        PrivateSettings ps = PrivateSettings(
            isPrivate: false, privateName: "DAMA", privateImage: "");
        // Manually map the document data to a UserProfile object
        var userData = UserProfile(
            uid: document['uid'] ?? '',
            firstName: document['firstName'] ?? '',
            phoneNumber: document['phoneNumber'] ?? '',
            bgImage: document['bgImage'] ?? '',
            profile: document['profile'] ?? '',
            privateSettings: ps,
            bg: BackgroundCOLOR(Appbar: "", body: ""),
            friends: List<String>.from(document['friends'] ?? []),
            describes: dse,
            inOnline: document['inOnline'] ?? false,
            isactivatePrivate: document['isactivatePrivate'] ?? false,
            groupId: List<String>.from(document['groupId'] ?? []),
            nearbyCoordinates: near,
            lockSettings: LockSettings(password: "", isLock: false, users: []));
        print("user data${userData}");
        String cleanedNumber = selectedContact.phonenumber
            .replaceAll(RegExp(r'\D'), '')
            .substring(0, 10);
        // print("cleaned number$cleanedNumber");
        if (cleanedNumber == userData.phoneNumber) {
          isFound = true;
          print("firstname ${userData.firstName} and uid ${userData.uid}");
          Navigator.pushNamed(
            context,
            MobileChatScreen.routeName,
            arguments: {
              'name': userData.firstName,
              'uid': userData.uid,
            },
          );
        }
      }

      if (!isFound) {
        showSnackBar(
          context,
          'This number does not exist on this app.',
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

/////////////////////////////////////////////////////////////////////////////////////
  Future<UserProfile?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      // Remove all non-digit characters from the phone number
      String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Ensure that only the last 10 digits are used
      formattedNumber = formattedNumber.length > 10
          ? formattedNumber.substring(formattedNumber.length - 10)
          : formattedNumber;

      print("Formatted phone number: $formattedNumber");

      // Query the 'users' collection for a document with the specified phone number
      var querySnapshot = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedNumber)
          .get();

      // Check if any document was found
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query
        var document = querySnapshot.docs.first;

        // Check if the document data is not null and has the expected structure
        var documentData = document.data();
        if (documentData != null) {
          // Log document data before manually mapping
          print("Document data: $documentData");

          NearbyCoordinates near = NearbyCoordinates(
              nearby: documentData["nearbyCoordinates"]["nearby"],
              latitude: documentData["nearbyCoordinates"]["latitude"],
              longitude: documentData["nearbyCoordinates"]["longitude"],
              radius: documentData["nearbyCoordinates"]["radius"]);
          Description dse = Description(
              descriptio: documentData["describes"]["descriptio"],
              dateTime: DateTime.fromMillisecondsSinceEpoch(
                  (documentData["describes"]["dateTime"])));
          PrivateSettings ps = PrivateSettings(
              isPrivate: false, privateName: "DAMA", privateImage: "");
          // Manually map the document data to a UserProfile object
          var userProfile = UserProfile(
              uid: documentData['uid'] ?? '',
              firstName: documentData['firstName'] ?? '',
              phoneNumber: documentData['phoneNumber'] ?? '',
              bgImage: documentData['bgImage'] ?? '',
              profile: documentData['profile'] ?? '',
              privateSettings: ps,
              bg: BackgroundCOLOR(Appbar: "", body: ""),
              friends: List<String>.from(documentData['friends'] ?? []),
              describes: dse,
              inOnline: documentData['inOnline'] ?? false,
              isactivatePrivate: documentData['isactivatePrivate'] ?? false,
              groupId: List<String>.from(documentData['groupId'] ?? []),
              nearbyCoordinates: near,
              lockSettings:
                  LockSettings(password: "", isLock: false, users: []));

          // Log the manually mapped UserProfile
          print("Mapped UserProfile: $userProfile");

          // Return the mapped user profile
          return userProfile;
        } else {
          print("Document data is null");
        }
      } else {
        print("No user found with phone number: $formattedNumber");
      }
    } catch (e) {
      print("Error fetching user by phone number: $e");
    }

    return null; // Return null if no user was found or an error occurred
  }

  Future<dynamic> getUserAttribute(String attributeName) async =>
      (await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get())
          .data()?['$attributeName'];
}
