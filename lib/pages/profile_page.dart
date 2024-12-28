import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:chat_app/services/images_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late double _deviceHeight;
  late double _deviceWidth;
  final ImagesService _imagesService = ImagesService();
  final AuthMethod _auth = AuthMethod();

  @override
  void initState() {
    super.initState();
    // Ambil gambar yang sudah ada saat pertama kali widget dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StorageService>(context, listen: false).fetchImages();
    });
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
    return Consumer<StorageService>(
      builder: (context, storageService, child) {
        final List<String> imgUrls = storageService.imgUrls;

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
                print("User: $user");
                return Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _deviceWidth * 0.03,
                      vertical: _deviceHeight * 0.02,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: imgUrls.isNotEmpty
                                  ? NetworkImage(imgUrls.last)
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
                                  onPressed: () async {
                                    _imagesService.uploadImageToFirestore(context);
                                  },
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
                        SizedBox(height: 20),
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Halo nama saya bla bla bla",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

}
