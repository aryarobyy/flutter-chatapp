class RoomModel {
  final String roomType;
  final String roomName;
  final List<String> members;
  final String imageUrl;
  final String roomId;

  RoomModel({
    required this.roomType,
    required this.roomName,
    required this.members,
    required this.imageUrl,
    required this.roomId
  });

  Map<String, dynamic> toMap() {
    return {
      'roomType' : roomType,
      'roomName' : roomName,
      'members' : members
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      roomType: map['roomType'] ?? '',
      roomName: map['roomName'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      imageUrl: map['image'] ?? '',
      roomId: map['roomId'] ?? '',
    );
  }
}
