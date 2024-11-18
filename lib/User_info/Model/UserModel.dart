import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserProfile {
  String firstName;
  String profile; // File path as String
  Description describes; // Corrected to use proper class
  PrivateSettings privateSettings;
  NearbyCoordinates nearbyCoordinates;
  String phoneNumber;
  String bgImage;
  final List<String> groupId;
  bool inOnline;
  String uid;
  LockSettings lockSettings;
  bool isactivatePrivate;
  List<String> friends = [];
  BackgroundCOLOR bg;

  UserProfile(
      {required this.firstName,
      required this.profile,
      required this.describes,
      required this.privateSettings,
      required this.nearbyCoordinates,
      required this.phoneNumber,
      required this.bgImage,
      required this.groupId,
      required this.inOnline,
      required this.uid,
      required this.lockSettings,
      required this.isactivatePrivate,
      required this.friends,
      required this.bg});

  // JSON serialization methods
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
        isactivatePrivate: json['isactivatePrivate'],
        inOnline: json['inOnline'],
        firstName: json['firstName'],
        uid: json['uid'],
        nearbyCoordinates:
            NearbyCoordinates.fromJson(json['nearbyCoordinates']),
        phoneNumber: json['phoneNumber'],
        groupId: List<String>.from(json['groupId']),
        profile: json['profile'],
        lockSettings:
            LockSettings.fromJson(json['lockSettings'] as Map<String, dynamic>),
        privateSettings: PrivateSettings.fromJson(
            json['privateSettings'] as Map<String, dynamic>),
        bgImage: json['bgImage'],
        describes:
            Description.fromJson(json['describes'] as Map<String, dynamic>),
        friends: List<String>.from(json['friends']),
        bg: BackgroundCOLOR.fromJson(json["bg"] as Map<String, dynamic>)
        // Fixed deserialization
        );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'profile': profile,
      'describes': describes.toJson(), // Fixed serialization
      'privateSettings': privateSettings.toJson(),
      'nearbyCoordinates': nearbyCoordinates.toJson(),
      'phoneNumber': phoneNumber,
      'bgImage': bgImage,
      'groupId': groupId,
      'inOnline': inOnline,
      'uid': uid,
      "friends": friends,
      'lockSettings': lockSettings.toJson(),
      "isactivatePrivate": isactivatePrivate,
      "bg": bg.toJson()
    };
  }

  // Map serialization methods
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
        firstName: map['firstName'],
        profile: map['profile'],
        describes: Description.fromMap(map['describes']),
        privateSettings: PrivateSettings.fromMap(map['privateSettings']),
        nearbyCoordinates: NearbyCoordinates.fromMap(map['nearbyCoordinates']),
        phoneNumber: map['phoneNumber'],
        bgImage: map['bgImage'],
        groupId: List<String>.from(map['groupId']),
        inOnline: map['inOnline'],
        uid: map['uid'],
        lockSettings: LockSettings.fromMap(map['lockSettings']),
        isactivatePrivate: map['isactivatePrivate'], // Possible source of error
        friends: List<String>.from(map['friends']),
        bg: BackgroundCOLOR.fromMap(map["bg"]));
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'profile': profile,
      'describes': describes.toMap(), // Fixed serialization
      'privateSettings': privateSettings.toMap(),
      'nearbyCoordinates': nearbyCoordinates.toMap(),
      'phoneNumber': phoneNumber,
      'bgImage': bgImage,
      'groupId': groupId,
      'inOnline': inOnline,
      'uid': uid,
      'lockSettings': lockSettings.toMap(),
      "friends": friends,
      "isactivatePrivate": isactivatePrivate,
      "bg": bg.toMap()
    };
  }
}

// Corrected Description class
class Description {
  String descriptio;
  DateTime dateTime;

  Description({
    required this.descriptio,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'descriptio': descriptio,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory Description.fromMap(Map<String, dynamic> map) {
    return Description(
      descriptio: map['descriptio'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
    );
  }

  // Change this method to accept a Map
  factory Description.fromJson(Map<String, dynamic> json) {
    return Description.fromMap(json);
  }

  String toJson() => json.encode(toMap());

  // Remove this method if you're not using it
  // factory Description.fromJsonString(String source) =>
  //     Description.fromMap(json.decode(source) as Map<String, dynamic>);
}

// Other Classes are the same

class NearbyCoordinates {
  bool nearby;
  double latitude;
  double longitude;
  int radius;

  NearbyCoordinates({
    required this.nearby,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  // JSON serialization methods
  factory NearbyCoordinates.fromJson(Map<String, dynamic> json) {
    return NearbyCoordinates(
        nearby: json['nearby'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        radius: json['radius']);
  }

  Map<String, dynamic> toJson() {
    return {
      'nearby': nearby,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius
    };
  }

  factory NearbyCoordinates.fromMap(Map<String, dynamic> map) {
    return NearbyCoordinates(
        nearby: map['nearby'],
        latitude: map['latitude'],
        longitude: map['longitude'],
        radius: map['radius']);
  }

  Map<String, dynamic> toMap() {
    return {
      'nearby': nearby,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius
    };
  }
}

class LockSettings {
  String password;
  bool isLock;
  List<String> users;

  LockSettings({
    required this.password,
    required this.isLock,
    required this.users,
  });

  // Factory constructor to create a LockSettings instance from a JSON Map
  factory LockSettings.fromJson(Map<String, dynamic> json) {
    return LockSettings(
      password: json['password'] ?? '', // Default to empty string if null
      isLock: json['isLock'] ?? false, // Default to false if null
      users: List<String>.from(
          json['users'] ?? []), // Default to empty list if null
    );
  }

  // Convert a LockSettings instance to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'isLock': isLock,
      'users': users,
    };
  }

  // Factory constructor to create a LockSettings instance from a Map
  factory LockSettings.fromMap(Map<String, dynamic> map) {
    return LockSettings(
      password: map['password'] ?? '', // Default to empty string if null
      isLock: map['isLock'] ?? false, // Default to false if null
      users: List<String>.from(
          map['users'] ?? []), // Default to empty list if null
    );
  }

  // Convert a LockSettings instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'isLock': isLock,
      'users': users,
    };
  }

  @override
  String toString() {
    return 'LockSettings(isLock: $isLock, lockType: $password, lockDate: $users)';
  }
}

class PrivateSettings {
  bool isPrivate;
  String privateName;
  String privateImage; // File path as String

  PrivateSettings({
    required this.isPrivate,
    required this.privateName,
    required this.privateImage,
  });

  // JSON serialization methods
  factory PrivateSettings.fromJson(Map<String, dynamic> json) {
    return PrivateSettings(
      isPrivate: json['isPrivate'],
      privateName: json['privateName'],
      privateImage: json['privateImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPrivate': isPrivate,
      'privateName': privateName,
      'privateImage': privateImage,
    };
  }

  factory PrivateSettings.fromMap(Map<String, dynamic> map) {
    return PrivateSettings(
      isPrivate: map['isPrivate'],
      privateName: map['privateName'],
      privateImage: map['privateImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isPrivate': isPrivate,
      'privateName': privateName,
      'privateImage': privateImage,
    };
  }
}

class friendprofile {
  String name;
  String number;
  Description describes;
  String profile;
  friendLockSettings locksettings;
  String appbar;
  String body;

  friendprofile(
      {required this.name,
      required this.number,
      required this.describes,
      required this.locksettings,
      required this.profile,
      required this.appbar,
      required this.body});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'number': number,
      'describes': describes.toMap(),
      'profile': profile,
      "appbar": appbar,
      "body": body
    };
  }

  factory friendprofile.fromMap(Map<String, dynamic> map) {
    return friendprofile(
        name: (map['name'] ?? '') as String,
        number: (map['number'] ?? '') as String,
        describes:
            Description.fromMap(map['describes'] as Map<String, dynamic>),
        locksettings: friendLockSettings.fromMap(map['lockSettings']),
        profile: map['profile'],
        appbar: map["appbar"],
        body: map["body"]);
  }
}

class friendLockSettings {
  String password;
  bool isLock;
  List<String> users;

  friendLockSettings({
    required this.password,
    required this.isLock,
    required this.users,
  });

  // Factory constructor to create a LockSettings instance from a JSON Map
  factory friendLockSettings.fromJson(Map<String, dynamic> json) {
    return friendLockSettings(
      password: json['password'] ?? '', // Default to empty string if null
      isLock: json['isLock'] ?? false, // Default to false if null
      users: List<String>.from(json['users'] ?? []),
      // Default to empty list if null
    );
  }

  // Convert a LockSettings instance to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'isLock': isLock,
      'users': users,
    };
  }

  // Factory constructor to create a LockSettings instance from a Map
  factory friendLockSettings.fromMap(Map<String, dynamic> map) {
    return friendLockSettings(
      password: map['password'] ?? '', // Default to empty string if null
      isLock: map['isLock'] ?? false, // Default to false if null
      users: List<String>.from(map['users'] ?? []),
      // Default to empty list if null
    );
  }

  // Convert a LockSettings instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'isLock': isLock,
      'users': users,
    };
  }

  @override
  String toString() {
    return 'LockSettings(isLock: $isLock, lockType: $password, lockDate: $users)';
  }
}

class BackgroundCOLOR {
  String Appbar;
  String body;

  BackgroundCOLOR({
    required this.Appbar,
    required this.body,
  });

  Map<String, dynamic> toMap() {
    return {
      'Appbar': Appbar,
      'body': body,
    };
  }

  factory BackgroundCOLOR.fromMap(Map<String, dynamic> map) {
    return BackgroundCOLOR(
      Appbar: map['Appbar'],
      body: map["body"],
    );
  }

  // Change this method to accept a Map
  factory BackgroundCOLOR.fromJson(Map<String, dynamic> json) {
    return BackgroundCOLOR.fromMap(json);
  }

  String toJson() => json.encode(toMap());

  // Remove this method if you're not using it
  // factory Description.fromJsonString(String source) =>
  //     Description.fromMap(json.decode(source) as Map<String, dynamic>);
}
