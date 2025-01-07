import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:chat_app/services/images_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/widget/text_field_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  late double _deviceHeight;
  late double _deviceWidth;
  final ImagesService _imagesService = ImagesService();
  final AuthMethod _auth = AuthMethod();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StorageService>(context, listen: false).fetchImages();
    });
  }

  void handleUploadImage() async {
    try {
      final res = await _imagesService.uploadImage(context);

      if (res == null || res.isEmpty) {
        print("Image upload failed or returned an empty response.");
        return;
      }

      final uploaded = {
        'image': res
      };
      print("Response: $res");
      print("Uploaded img: $uploaded");

      final uploadRes = await _auth.updateUser(uploaded);
      print("Success: $uploadRes");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: _buildProfileUi(),
    );
  }
  Widget _buildProfileUi() {
        return StreamBuilder<String>(
          stream: _auth.getCurrentUserIdStream(),
          builder: (context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshots.hasError || !snapshots.hasData) {
              return Center(
                child: Text("Error fetching user information"),
              );
            }
            final currUser = snapshots.data;
            print("Current user: $currUser");
            return StreamBuilder<UserModel>(
              stream: _auth.getUserById(currUser!),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (profileSnapshot.hasError || !profileSnapshot.hasData) {
                  return Center(
                    child: Text("Error fetching user profile"),
                  );
                }
                final user = profileSnapshot.data!;
                final imgUrl = user.imageUrl;
                print("Image $user");
                return Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _deviceWidth * 0.03,
                      vertical: _deviceHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: imgUrl.isNotEmpty
                                  ? NetworkImage(imgUrl)
                                  : AssetImage("assets/images/profile.png")
                              as ImageProvider,
                              radius: 70,
                            ),
                            Positioned(
                              bottom: 3,
                              right: 2,
                              child: Container(
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
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
                        SizedBox(height: 40),
                        SizedBox(
                          width: 350,
                          child: MyTextField2(
                              controller: _nameController,
                              name: user.name,
                              prefixIcon: Icons.person,
                              inputType: TextInputType.name
                          )
                        ),
                        SizedBox(height: 20,),
                        SizedBox(
                          width: 350,
                          child: MyTextField2(
                              controller: _emailController,
                              name: user.email,
                              prefixIcon: Icons.email_outlined,
                              inputType: TextInputType.emailAddress
                          ),
                        ),
                        SizedBox(height: 26,),
                        ElevatedButton(
                            onPressed: () {
                              
                            },
                            child: Text("Submit")
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
  }

}
