import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/update_profile.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:chat_app/services/images_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/widget/button2.dart';
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
            child: Text(
              "Unable to load user information",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        final currUser = snapshots.data;
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
                child: Text(
                  "Unable to load user profile",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            final user = profileSnapshot.data!;
            final imgUrl = user.imageUrl;

            return Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
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
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "Name",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Divider(height: 32, thickness: 1),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Divider(height: 32, thickness: 1),
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "About",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        user.bio,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 30,),
                      SizedBox(
                        width: 150,
                        child: MyButton2(
                            text: "Edit Your Profile",
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => UpdateProfile()
                                  )
                              );
                            }
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

}
