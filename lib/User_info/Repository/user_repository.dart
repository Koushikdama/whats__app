// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chatting_app/Common/Repository/commonFirebase.dart';
import 'package:chatting_app/Common/utils/functions.dart';

import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:chatting_app/colors.dart';
import 'package:chatting_app/screens/mobile_layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Future<UserProfile?> getCurrentuserData() async {
    var userData =
        await firestore.collection("users").doc(auth.currentUser?.uid).get();
    UserProfile? user;
    if (userData.data() != null) {
      user = UserProfile.fromMap(userData.data()!);
      print("user ${user}");
    }
    return user;
  }

  void saveUserDataToFirebase({
    required String name,
    required String description,
    required File? profilePic,
    required File? bgimage,
    required ProviderRef ref,
    required String mobilenumber,
    required BuildContext context,
  }) async {
    try {
      print("repository");
      // Get the current user's UID
      String uid = auth.currentUser!.uid;
      User? currentUser = auth.currentUser;

      if (currentUser == null) {
        showSnackBar(context, 'User not authenticated.');
        return; // Exit if user is not authenticated
      }

      String photoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';
      String bgPhotourl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      // Upload profile picture if provided
      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'profilePic/$uid',
              profilePic,
            );
      }

      // Upload background image if provided
      if (bgimage != null) {
        bgPhotourl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'BG_IMAGE/$uid',
              bgimage,
            );
      }

      //print("success");

      // Create the updated user profile
      var user = UserProfile(
          firstName: name,
          profile: photoUrl,
          describes:
              Description(descriptio: description, dateTime: DateTime.now()),
          privateSettings: PrivateSettings(
              isPrivate: false, privateName: name, privateImage: photoUrl),
          nearbyCoordinates: NearbyCoordinates(
              latitude: 0, longitude: 0, nearby: false, radius: 0),
          inOnline: true,
          uid: uid,
          isactivatePrivate: false,
          bgImage: bgPhotourl,
          groupId: [],
          phoneNumber: mobilenumber,
          lockSettings: LockSettings(isLock: false, password: "", users: []),
          friends: [uid],
          bg: BackgroundCOLOR(
              Appbar: appBarColor.value.toRadixString(16).padLeft(8, '0'),
              body:
                  "${'#${backgroundColor.value.toRadixString(16).padLeft(8, '0')}-' + '#${backgroundColor.value.toRadixString(16).padLeft(8, '0')}'}"));
      print("user ${user}");
      // Update the user data in Firestore
      await firestore.collection('users').doc(uid).set(user.toMap());

      // Navigate to the next screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> savePrivateDetails({
    required String updated,
    required String name,
    required File? image,
    required ProviderRef ref,
    required BuildContext context,
    required bool isPrivateValue,
  }) async {
    String uid = auth.currentUser!.uid;

    // Get the 'isPrivate' field value

    if (updated == 'privatesettings') {
      //var isPrivateValue = await getStatus('privateSettings.isPrivate');
      // print("repoisPrivateValue=${isPrivateValue} ");

      // Default private photo URL
      String privatePhotoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      // If image is provided, upload to Firebase Storage
      if (image != null) {
        try {
          privatePhotoUrl = await ref
              .read(commonFirebaseStorageRepositoryProvider)
              .storeFileToFirebase(
                'private_profilePic/$uid',
                image,
              );
        } catch (e) {
          // print("Error uploading image: $e");
          //showSnackBar(context, "Error uploading image");
          return; // Exit early if image upload fails
        }
      }

      // Create PrivateSettings object
      var privateSettings = PrivateSettings(
        isPrivate:
            isPrivateValue ?? false, // Handle null case with a default value
        privateName: name,
        privateImage: privatePhotoUrl,
      );
      // print("privateSettings =${privateSettings.isPrivate}");

      // Update Firestore with the new private settings
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'privateSettings': privateSettings.toJson(),
        });
        showSnackBar(context, "Private details updated successfully");
      } catch (e) {
        // print("Error updating private details: $e");
        showSnackBar(context, "Error updating private details");
      }
    }
  }

  void updateLocation(
      {required double latitude,
      required bool nearby,
      required double longitude,
      required BuildContext context,
      required ProviderRef ref,
      required int radius}) async {
    // Retrieve the user's UID from the current authenticated user
    String uid = auth.currentUser!.uid;
    var isPrivateValue = await getStatus('nearbyCoordinates.nearby');

    // Create a NearbyCoordinates object with the provided latitude and longitude
    var userLocation = NearbyCoordinates(
      latitude: latitude,
      longitude: longitude,
      nearby: nearby,
      radius:
          radius, // Assuming 'nearby' is required, you can adjust this if needed
    );

    try {
      // Update the 'nearbyCoordinates' field in the user's Firestore document
      await FirebaseFirestore.instance
          .collection('users') // Target the 'users' collection
          .doc(uid) // Target the specific user by their UID
          .update({
        'nearbyCoordinates': userLocation.toJson(), // Update the location
      });

      // Show a snackbar message to confirm the location update
      showSnackBar(context, "Location updated successfully");
      Navigator.pop(context);
    } catch (e) {
      // Log the error or show an error message in case of failure
      // print("Error updating location: $e");
      showSnackBar(context, "Failed to update location");
    }
  }

  void updateprofile(
      {required BuildContext context,
      required String name,
      required String profilePic,
      required String description,
      required String bgimage,
      required String mobilenumber}) async {
    // Retrieve the user's UID from the current authenticated user
    String uid = auth.currentUser!.uid;

    // Create a NearbyCoordinates object with the provided latitude and longitude
    // Assuming 'nearby' is required, you can adjust this if needed);
    Description desc =
        Description(descriptio: description, dateTime: DateTime.now());
    try {
      // Update the 'nearbyCoordinates' field in the user's Firestore document
      await FirebaseFirestore.instance
          .collection('users') // Target the 'users' collection
          .doc(uid) // Target the specific user by their UID
          .update({
        'bgImage': bgimage,
        "firstName": name,
        "profile": profilePic,
        "describes": desc.toMap() // Update the location
      });

      // Show a snackbar message to confirm the location update
      showSnackBar(context, "Profile updated successfully");
      Navigator.pushNamed(context, MobileLayoutScreen.routeName);
    } catch (e) {
      // Log the error or show an error message in case of failure
      // print("Error updating location: $e");
      showSnackBar(context, "Failed to update location");
    }
  }

  void updatelock({
    required BuildContext context,
    required String password,
  }) async {
    // Retrieve the user's UID from the current authenticated user
    String uid = auth.currentUser!.uid;

    // Create a NearbyCoordinates object with the provided latitude and longitude
    // Assuming 'nearby' is required, you can adjust this if needed);
    try {
      // Update the 'nearbyCoordinates' field in the user's Firestore document
      await FirebaseFirestore.instance
          .collection('users') // Target the 'users' collection
          .doc(uid) // Target the specific user by their UID
          .update({
        "lockSettings.password": password
        // Update the location
      });

      // Show a snackbar message to confirm the location update
      showSnackBar(context, "Profile updated successfully");
    } catch (e) {
      // Log the error or show an error message in case of failure
      // print("Error updating location: $e");
      showSnackBar(context, "Failed to update location");
    }
  }

  Stream<UserProfile> userData(String userId) async* {
    yield* firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((event) async {
      var userProfile = UserProfile.fromMap(event.data()!);

      // Fetch contacts asynchronously
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      for (Contact c in contacts) {
        print("${c.phones[0]} ending");
      }

      // You can modify the userProfile with the contacts data here if necessary
      // For example, adding the contact list to the user profile, if it has such a field
      // userProfile.contacts = contacts; // Ensure `contacts` is a field in `UserProfile`

      return userProfile;
    });
  }

  void setUserState(bool isonline) async {
    firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .update({'inOnline': isonline, 'isactivatePrivate': false});
    setisPrivate(false);
  }

  void setisPrivate(bool isprivate) async {
    firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .update({'isactivatePrivate': isprivate});
  }

  void setbackground(String appbar, String body) async {
    try {
      // Check if the user is authenticated
      if (auth.currentUser == null) {
        print("No user is logged in");
        return;
      }

      print("Updating background colors in Firestore...");
      // Update the Firestore document
      await firestore
          .collection("users")
          .doc(auth.currentUser!.uid) // Use the current user's UID
          .update({
        'bg.Appbar': appbar, // Update the Appbar color
        'bg.body': body, // Update the Body color
      });

      print("Background colors updated successfully!");
    } catch (e) {
      print("Error updating background colors: $e");
    }
  }

  Future<bool> getPasswordAttribute(String password) async {
    try {
      // Reference the user's document
      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(auth.currentUser!.uid).get();

      // Check if the document exists
      if (userDoc.exists) {
        // print("id executer");
        // Retrieve a specific attribute value from the document
        Map<String, dynamic> userData = userDoc.data() as Map<String,
            dynamic>; // Replace 'password' with the actual attribute name
        // Optionally, compare with the provided password
        return userData['lockSettings']['password'] ==
            password; // Return true if they match
      } else {
        // print("User document does not exist.");
        return false;
      }
    } catch (e) {
      // print("Error retrieving password: $e");
      return false; // Return false in case of an error
    }
  }

  void lockStatus(BuildContext context, bool islock, String uid) async {
    // Reference to the user document
    final userDocRef = firestore.collection("users").doc(auth.currentUser!.uid);

    // Use a transaction to ensure atomicity
    await firestore.runTransaction((transaction) async {
      // Get the current data of the document
      DocumentSnapshot userDoc = await transaction.get(userDocRef);

      if (userDoc.exists) {
        // Cast the document data to Map<String, dynamic>
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // print("userData ${userData}");

        // Get the current groupId array, default to an empty list if it doesn't exist
        // List<dynamic> lockusers = userData['lockSettings']['lockChats'] ?? [];
        List<dynamic> userslock = userData['lockSettings']['users'] ?? [];

        // print("lockusers == and ${userslock}");

        // Check if uid exists in the array
        if (islock) {
          if (userData['lockSettings']['password'] == "") {
            showSnackBar(context, "PLEASE SET PASSWORD FIRSTLY");
          } else {
            // Add uid if not already present
            if (!userslock.contains(uid)) {
              // print("if block lock statsu");

              userslock.add(uid);
            }
          }
        } else {
          // print("else block lock statsu");

          // Remove uid if it exists

          userslock.remove(uid);
        }

        // Update the document with the new groupId array
        transaction.update(userDocRef, {'lockSettings.users': userslock});
      }
    });
  }

  Future<friendprofile?> fetchProfileDetails(
      BuildContext context, String receiverId) async {
    try {
      // Use `await` to wait for the document snapshot
      var userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(receiverId)
          .get();
      var currentuserSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser!.uid)
          .get();
      // Check if the document exists
      if (userSnapshot.exists && currentuserSnapshot.exists) {
        print("User data: ${userSnapshot.data()}");

        // Cast the document data to a Map
        var userData = userSnapshot.data() as Map<String, dynamic>;
        var currentuser = currentuserSnapshot.data() as Map<String, dynamic>;
        friendprofile profileDetails = friendprofile(
            name: await getnamefromphone(userData["phoneNumber"]) != "NOT OCCUR"
                ? await getnamefromphone(userData["phoneNumber"])
                : userData["firstName"],
            locksettings:
                friendLockSettings.fromMap(currentuser['lockSettings'] ?? {}),
            describes: Description.fromMap(userData['describes']),
            number: userData['phoneNumber'] ?? '',
            profile: userData['profile'] ?? '',
            body: currentuser['bg']["body"],
            appbar: currentuser["bg"]["Appbar"]);

        return profileDetails; // Return the UserProfile instance
      } else {
        print("No user found with the ID: $receiverId");
        return null; // Return null if the user does not exist
      }
    } catch (error) {
      print("Error fetching user data: $error");
      return null; // Return null on error
    }
  }

  Map<String, dynamic> containsPhoneNumber(
      List<Contact> contacts, String numberToCheck) {
    // print("contacts: ${contacts}");

    // Remove the country code '+91' if it exists at the start of the number
    if (numberToCheck.startsWith('+91')) {
      numberToCheck = numberToCheck.replaceFirst('+91', '');
    }

    // Normalize the input number by removing non-digit characters
    String normalizedInput = numberToCheck.replaceAll(
        RegExp(r'\D'), ''); // Remove non-digit characters

    // If the number contains more than 10 digits, keep only the last 10 digits
    if (normalizedInput.length > 10) {
      normalizedInput = normalizedInput.substring(normalizedInput.length - 10);
    }

    for (var contact in contacts) {
      for (var phone in contact.phones) {
        // Normalize the phone number in the contact list for comparison
        String contactNumber = phone.normalizedNumber;

        // If the contact's normalized number has more than 10 digits, keep the last 10 digits
        if (contactNumber.length > 10) {
          contactNumber = contactNumber.substring(contactNumber.length - 10);
        }

        // print(
        //     "Checking contact phone: $contactNumber against normalized input: $normalizedInput");

        if (contactNumber == normalizedInput) {
          return {
            'exists': true,
            'displayName':
                contact.displayName // Return the display name if found
          }; // Number found
        }
      }
    }

    return {
      'exists': false,
      'displayName': null // Return null if not found
    }; // Number not found
  }

  Future<bool?> getStatus(String field) async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (docSnapshot.exists) {
      return docSnapshot.data()?[field] as bool?; // Return the field value
    }

    return null; // Return null if the document or field doesn't exist
  }
}
