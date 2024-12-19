import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String imageUrl;
  late DateTime lastActive;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.imageUrl,
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
      userId: _json["user_id"] ?? "",
      name: _json["name"] ?? "",
      email: _json["email"] ?? "",
      imageUrl: _json["image"] ?? "",
      lastActive: lastActiveDateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "last_active": lastActive.toIso8601String(),
      "image": imageUrl,
    };
  }

  String lastDayActive() {
    return "${lastActive.month}/${lastActive.day}/${lastActive.year}";
  }

  bool wasRecentlyActive() {
    return DateTime.now().difference(lastActive).inHours < 2;
  }
}
