import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/update_profile.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:chat_app/services/images_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/widget/text_field_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late double _deviceHeight;
  late double _deviceWidth;
  final AuthMethod _auth = AuthMethod();

  @override
  void initState() {
    super.initState();
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
                      ],
                    ),
                    SizedBox(height: 40),
                    Column(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 32,

                          ),
                        ),
                        SizedBox(height: 30,),
                        Text(
                            user.email,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 24
                          ),
                        ),
                        Text(
                          user.bio,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300
                          ),
                        ),
                        SizedBox(height: 28,),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateProfile(),
                              ),
                            );
                          },
                          child: Text("Helo"),
                        )
                      ],
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
