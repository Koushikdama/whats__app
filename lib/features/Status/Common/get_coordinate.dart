import 'dart:math';

import 'package:chatting_app/Common/utils/functions.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class NearbyUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to convert degrees to radians
  double _toRadians(double degree) => degree * pi / 180;

  // Function to calculate distance between two coordinates
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in kilometers
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in kilometers
  }

  // Main function to get nearby users within a certain radius
  Future<List<UserProfile>> getNearbyUsers(double radius) async {
    try {
      // Ensure the user is logged in
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("User is not logged in");
      }

      // Get the current user ID
      final String currentUserId = currentUser.uid;

      // Fetch the logged-in user's data (including location and friends list)
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUserId).get();

      // Check if the document exists and has necessary data
      if (!doc.exists) {
        throw Exception("User data not found");
      }

      UserProfile usersdata =
          UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      final double currentUserLat = usersdata.nearbyCoordinates.latitude;
      final double currentUserLon = usersdata.nearbyCoordinates.longitude;
      final List<String> friendList = List<String>.from(usersdata.groupId);

      // List to store user profiles of users within the radius who are not friends
      List<UserProfile> nearbyUsers = [];

      // Fetch all users from Firestore
      final QuerySnapshot usersSnapshot =
          await _firestore.collection('users').get();

      for (final DocumentSnapshot userDoc in usersSnapshot.docs) {
        final String userId = userDoc.id;

        // Skip if the user is the logged-in user or already a friend
        if (userId == currentUserId || friendList.contains(userId)) {
          continue;
        }

        // Ensure location data exists before accessing it
        if (userDoc['NearbyCoordinates'] != null &&
            userDoc['NearbyCoordinates']['latitude'] != null &&
            userDoc['NearbyCoordinates']['longitude'] != null) {
          final double userLat = userDoc['NearbyCoordinates']['latitude'];
          final double userLon = userDoc['NearbyCoordinates']['longitude'];

          // Calculate distance
          final double distance = _calculateDistance(
              currentUserLat, currentUserLon, userLat, userLon);

          // If within radius, add the user's profile data to the list
          if (distance <= radius) {
            // Parse the user's profile data
            UserProfile userProfile =
                UserProfile.fromMap(userDoc.data() as Map<String, dynamic>);
            nearbyUsers.add(userProfile);
          }
        }
      }

      return nearbyUsers;
    } catch (e) {
      return [];
    }
  }

  // Function to fetch users in both friends and contacts lists
  Future<List<String>> getUsersInBothFriendsAndContacts(String userId) async {
    // Fetch the current user's friends and contacts list
    List<Contact> contacts = [];
    final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    final List<String> friendsList = List<String>.from(userDoc['friends']);
    print("friend list${friendsList}");
    final List<String> contactsList = [];
    contacts = await FlutterContacts.getContacts(withProperties: true);

    for (Contact c in contacts) {
      var userDataFirebase = await _firestore
          .collection('users')
          .where(
            'phoneNumber',
            isEqualTo: c.phones[0].number.replaceAll(RegExp(r'\D'), ''),
          )
          .get();
      if (userDataFirebase.docs.isNotEmpty) {
        var userData = UserProfile.fromMap(userDataFirebase.docs[0].data());
        contactsList.add(userData.uid);
      }
    }
    // Create a set for efficient lookup of contacts in friends list
    final Set<String> contactsSet = Set.from(contactsList);

    // Find the intersection of friends and contacts
    List<String> usersInBothLists = friendsList
        .where((friendId) => contactsSet.contains(friendId))
        .toList();
    print("usersInBothLists${usersInBothLists}");
    return usersInBothLists;
  }
}

Future<void> removeOldStatuses() async {
  // Get the current timestamp.
  final currentTime = Timestamp.now();

  // Calculate 24 hours ago from the current time.
  final twentyFourHoursAgo = currentTime.toDate().subtract(Duration(hours: 24));

  // Reference to the 'status' collection.
  final statusCollection = FirebaseFirestore.instance.collection('status');

  try {
    // Fetch all users.
    final usersSnapshot = await statusCollection.get();
    print("usersSnapshot==${usersSnapshot.docs}");

    for (var userDoc in usersSnapshot.docs) {
      // Get the user's 'media' array.
      final media = userDoc['media'] as List<dynamic>?;

      if (media != null) {
        // Filter out media items older than 24 hours
        List<dynamic> updatedMedia = media.where((mediaItem) {
          final uploadAt = mediaItem['uploadAt'] as Timestamp?;
          if (uploadAt != null) {
            return uploadAt.toDate().isAfter(twentyFourHoursAgo);
          }
          return true; // Keep it if 'uploadAt' is null or invalid
        }).toList();

        // If there are changes (some media items are deleted)
        if (updatedMedia.length != media.length) {
          // Update the user's media array with the filtered media.
          await statusCollection
              .doc(userDoc.id)
              .update({'media': updatedMedia});
          print('Updated media for user ${userDoc.id}');
        }
      }
    }

    print("Old media removed successfully!");
  } catch (e) {
    print("Error removing old statuses: $e");
  }
}

Future<Map<String, dynamic>?> getUserInformation(String uid) async {
  try {
    // Reference to the users collection
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    // Get the document snapshot
    final snapshot = await userDoc.get();

    // Check if the document exists
    if (snapshot.exists) {
      // Return the user data as a Map
      return snapshot.data();
    } else {
      print('User with UID $uid does not exist.');
      return null;
    }
  } catch (e) {
    print('Error fetching user information: $e');
    return null;
  }
}

/// Fetches user details for the friends listed in the `friends` field
/// of a specific user's document in the `users` collection.
///
/// Returns a Future that completes with a List of Maps containing friend data.
Future<List<Map<String, dynamic>>> fetchFriendDetails() async {
  // Get the current user ID from Firebase Authentication
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  // If the user is not authenticated, return an empty list
  if (userId == null) {
    print("User is not authenticated.");
    return [];
  }

  // Reference to the 'users' collection in Firestore
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  List<Map<String, dynamic>> friendsData = [];

  try {
    // Fetch the user document to get the 'friends' array
    DocumentSnapshot userDoc = await usersCollection.doc(userId).get();

    if (!userDoc.exists) {
      print("User document not found.");
      return [];
    }

    // Get the 'friends' array from the user document
    List<dynamic> friendsArray = userDoc.get('friends');
    print("friendarray${friendsArray}");
    List<String> friendIds = List<String>.from(friendsArray);

    // Retrieve each friend's data individually
    for (String friendId in friendIds) {
      // Fetch each friend's document

      if (friendId != userId) {
        print("fri======end${friendId}");
        var data = await getUserInformation(friendId);
        if (data != null) {
          Map<String, dynamic> friendDetails = {
            'id': data["uid"],
            'profile':
                data['profile'] ?? '', // Provide fallback if field is missing
            'NAME':
                await getnamefromphone(data['phoneNumber']), // Provide fallback
          };

          friendsData.add(friendDetails);
        }
      }
    }
    print("friendsDatafriendsData${friendsData}");
    return friendsData;
  } catch (e) {
    print("Error fetching friend details: $e");
    return [];
  }
}

Future<UserProfile> getUserProfile(String uid) async {
  try {
    // Reference to the 'users' collection
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnapshot.exists) {
      // If the document exists, create a UserProfile object
      return UserProfile.fromMap(docSnapshot.data() as Map<String, dynamic>);
    } else {
      // If document doesn't exist, return a default UserProfile or throw an exception
      // For example, returning a default profile:
      return UserProfile(
        uid: '',
        firstName: 'Unknown',
        privateSettings: PrivateSettings(
            isPrivate: false, privateName: "", privateImage: ""),
        phoneNumber: '',
        describes: Description(descriptio: "", dateTime: DateTime.now()),
        groupId: [],
        profile: "",
        nearbyCoordinates: NearbyCoordinates(
            nearby: false, latitude: 0, longitude: 0, radius: 0),
        bgImage: "",
        inOnline: false,
        lockSettings: LockSettings(password: "", isLock: false, users: []),
        isactivatePrivate: false,
        friends: [],
        bg: BackgroundCOLOR(Appbar: "", body: ""),
      );
    }
  } catch (e) {
    print("Error fetching user data: $e");
    // Return a default UserProfile in case of error
    return UserProfile(
        uid: '',
        firstName: 'Unknown',
        privateSettings: PrivateSettings(
            isPrivate: false, privateName: "", privateImage: ""),
        phoneNumber: '',
        describes: Description(descriptio: "", dateTime: DateTime.now()),
        groupId: [],
        profile: "",
        nearbyCoordinates: NearbyCoordinates(
            nearby: false, latitude: 0, longitude: 0, radius: 0),
        bgImage: "",
        inOnline: false,
        lockSettings: LockSettings(password: "", isLock: false, users: []),
        isactivatePrivate: false,
        friends: [],
        bg: BackgroundCOLOR(Appbar: "", body: ""));
  }
}
