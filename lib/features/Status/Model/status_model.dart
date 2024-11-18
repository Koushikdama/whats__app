import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Media {
  final String mediaUrl; // URL of the media (image or video)
  final String mediaType; // Type of media (image or video)
  final List<Viewer> viewers; // List of viewers
  final List<Reply> replies; // List of replies for the media
  final String caption; // Caption for the media
  final DateTime uploadAt;

  Media(
      {required this.mediaUrl,
      required this.mediaType,
      required this.viewers,
      required this.replies,
      required this.caption, // New field added
      required this.uploadAt});

  // Convert a Media object to a Map
  Map<String, dynamic> toMap() {
    return {
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'viewers': viewers.map((viewer) => viewer.toMap()).toList(),
      'replies': replies.map((reply) => reply.toMap()).toList(),
      'caption': caption,
      'uploadAt': uploadAt
    };
  }

  // Create a Media object from a Map
  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      mediaUrl: map['mediaUrl'],
      mediaType: map['mediaType'],
      viewers: List<Viewer>.from(map['viewers']?.map((x) => Viewer.fromMap(x))),
      replies: List<Reply>.from(map['replies']?.map((x) => Reply.fromMap(x))),
      caption: map['caption'],
      uploadAt: map['uploadAt'] is Timestamp
          ? (map['uploadAt'] as Timestamp).toDate() // Convert if Timestamp
          : map['uploadAt'] as DateTime,
    ); // Directly assign if DateTime
  }
}

class Viewer {
  final String id; // Username of the viewer
  final DateTime viewedAt;
  final String profile;
  final String username; // Time when the media was viewed

  Viewer(
      {required this.username,
      required this.viewedAt,
      required this.profile,
      required this.id});

  // Convert a Viewer object to a Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'viewedAt': viewedAt.toIso8601String(),
      "profile": profile,
      "id": id
    };
  }

  // Create a Viewer object from a Map
  factory Viewer.fromMap(Map<String, dynamic> map) {
    return Viewer(
        username: map['username'],
        viewedAt: DateTime.parse(map['viewedAt']),
        profile: map["profile"],
        id: map["id"]);
  }
}

class Reply {
  final String replyId; // Unique identifier for the reply
  final String userId; // ID of the user who replied
  final String message; // Reply message
  final DateTime repliedAt; // Time when the reply was sent

  Reply({
    required this.replyId,
    required this.userId,
    required this.message,
    required this.repliedAt,
  });

  // Convert a Reply object to a Map
  Map<String, dynamic> toMap() {
    return {
      'replyId': replyId,
      'userId': userId,
      'message': message,
      'repliedAt': repliedAt.toIso8601String(),
    };
  }

  // Create a Reply object from a Map
  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      replyId: map['replyId'],
      userId: map['userId'],
      message: map['message'],
      repliedAt: DateTime.parse(map['repliedAt']),
    );
  }
}

class Status {
  final String uid; // User ID of the status creator
  String username; // Username of the status creator
  final String phoneNumber; // Phone number of the status creator
  final List<Media> media; // List of media (images and videos)
  final DateTime createdAt; // Timestamp when the status was created
  final String profilePic; // Profile picture of the status creator
  final String statusId; // Unique identifier for the status
  final List<String> whoCanSee; // List of user IDs who can see the status

  Status({
    required this.uid,
    required this.username,
    required this.phoneNumber,
    required this.media,
    required this.createdAt,
    required this.profilePic,
    required this.statusId,
    required this.whoCanSee,
  });

  // Convert a Status object to a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'phoneNumber': phoneNumber,
      'media': media.map((mediaItem) => mediaItem.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'profilePic': profilePic,
      'statusId': statusId,
      'whoCanSee': whoCanSee,
    };
  }

  // Create a Status object from a Map
  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'],
      username: map['username'],
      phoneNumber: map['phoneNumber'],
      media: List<Media>.from(map['media']?.map((x) => Media.fromMap(x))),
      createdAt: DateTime.parse(map['createdAt']),
      profilePic: map['profilePic'],
      statusId: map['statusId'],
      whoCanSee: List<String>.from(map['whoCanSee']),
    );
  }
}
