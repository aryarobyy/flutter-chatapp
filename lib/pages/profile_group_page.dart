import 'package:chat_app/component/snackbar.dart';
import 'package:chat_app/model/room_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/images_service.dart';
import 'package:flutter/material.dart';

class ProfileGroupPage extends StatefulWidget {
  final String roomId;

  const ProfileGroupPage({
    super.key,
    required this.roomId,
  });

  @override
  State<ProfileGroupPage> createState() => _ProfileGroupPageState();
}

class _ProfileGroupPageState extends State<ProfileGroupPage> {
  final ChatService _chat = ChatService();
  final AuthService _auth = AuthService();
  final ImagesService _imagesService = ImagesService();
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose()  {
    _nameController.dispose();
    super.dispose();
  }

  void handleUploadImage() async {
    try {
      final res = await _imagesService.uploadImage(context);

      if (res == null || res.isEmpty) {
        print("Image upload failed or returned an empty response.");
        return;
      }

      final uploaded = {'image': res};

      final uploadRes = await _chat.updateRoom(uploaded, widget.roomId);

      if (uploadRes?.imageUrl != null) {
        final deleteImage =
        await _imagesService.deleteImage(context, uploadRes!.imageUrl);
        print("Image deleted: $deleteImage");
        return;
      }
      print("Success: $uploadRes");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  void handleNameChange() async{
    setState(() {
      _isEditing = false;
    });

    if(_nameController.text.isEmpty){
      showSnackBar(context, "Nothing change");
      return;
    }

    final roomName = _nameController.text;
    final uploadData = {'roomName': roomName};

    await _chat.updateRoom(uploadData, widget.roomId);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Profile"),
        centerTitle: true,
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return StreamBuilder<RoomModel?>(
      stream: _chat.getRoomById(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Something went wrong."));
        }

        final data = snapshot.data!;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          backgroundImage: data.imageUrl.isNotEmpty
                              ? NetworkImage(data.imageUrl)
                              : const AssetImage("assets/images/profile.png") as ImageProvider,
                          radius: 70,
                        ),
                      ),
                      Positioned(
                    bottom: 3,
                    right: 2,
                    child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: handleUploadImage,
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: _isEditing
                          ? TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        onSubmitted: (_) => handleNameChange(),
                        autofocus: true,
                      )
                          : Text(
                        data.roomName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          if (!_isEditing) {
                            _nameController.text = data.roomName;
                          }
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                          if (_isEditing == false) {
                            handleNameChange();
                          }
                        },
                        icon: Icon(_isEditing ? Icons.check : Icons.edit)
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                Row(
                  children: [
                    const Text(
                      "Members: ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(child: _buildMemberList(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberList(BuildContext context) {
    return StreamBuilder<RoomModel?>
      (stream: _chat.getRoomById(widget.roomId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                ),
                title: Text("Loading..."),
              ),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red,
                ),
                title: Text("Error loading user."),
              ),
            );
          }
          final room = snapshot.data!;
          final _members = room.members;

          return ListView.builder(
            itemCount: room.members.length,
            itemBuilder: (context, index) {
              final userId = _members[index];
              return StreamBuilder<UserModel?>(
                stream: _auth.getUserById(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                        ),
                        title: Text("Loading..."),
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                        ),
                        title: Text("Error loading user."),
                      ),
                    );
                  }

                  final user = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.imageUrl.isNotEmpty
                            ? NetworkImage(user.imageUrl)
                            : const AssetImage(
                            "assets/images/profile.png",

                        )
                        as ImageProvider,
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(user.email),
                    ),
                  );
                },
              );
            },
          );
        }
      );
  }
}