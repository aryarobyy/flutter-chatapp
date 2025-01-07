import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  final String bio;
  late DateTime lastActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.bio,
    required this.lastActive,
  });

  factory UserModel.fromJSON(Map<String, dynamic> _json) {
    var lastActiveField = _json["last_active"];
    DateTime lastActiveDateTime;

    if (lastActiveField is Timestamp) {
      lastActiveDateTime = lastActiveField.toDate();
    } else if (lastActiveField is String) {
      try {
        lastActiveDateTime = DateTime.parse(lastActiveField);
      } catch (e) {
        print("Invalid date format for last_active: $lastActiveField");
        lastActiveDateTime = DateTime.now();
      }
    } else {
      lastActiveDateTime = DateTime.now();
    }

    return UserModel(
      uid: _json["uid"] ?? "",
      name: _json["name"] ?? "",
      email: _json["email"] ?? "",
      imageUrl: _json["image"] ?? "",
      bio: _json["bio"] ?? "",
      lastActive: lastActiveDateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "last_active": lastActive.toIso8601String(),
      "image": imageUrl,
      "bio": bio,
    };
  }

  @override
  String toString() {
    return 'UserModel(userId: $uid, name: $name, email: $email, image: $imageUrl, bio: $bio, lastActive: $lastActive)';
  }

  String lastDayActive() {
    return "${lastActive.month}/${lastActive.day}/${lastActive.year}";
  }

  bool wasRecentlyActive() {
    return DateTime.now().difference(lastActive).inHours < 2;
  }
}
