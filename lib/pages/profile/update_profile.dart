part of 'profile.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  late double _deviceHeight;
  late double _deviceWidth;
  final ImagesService _imagesService = ImagesService();
  final AuthService _auth = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

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

      final uploaded = {'image': res};

      final uploadRes = await _auth.updateUser(uploaded);
      if (uploadRes.imageUrl != null) {
        final deleteImage =
            await _imagesService.deleteImage(context, uploadRes.imageUrl);
        print("Image deleted: $deleteImage");
        return;
      }
      print("Success: $uploadRes");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  void handleSubmit() async {
    final _currUserId = await _auth.getCurrentUserId();

    if (_emailController.text.isEmpty ||
        _bioController.text.isEmpty ||
        _nameController.text.isEmpty) {
      showSnackBar(context, "No one get update");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: _currUserId),
        ),
      );
    }
    try {
      if (!isValidEmail(_emailController.text.trim()) &&
          _emailController.text.trim().isNotEmpty) {
        showSnackBar(context, "Wrong format email");
        return;
      }

      final currentUser = await _auth.getUserById(_currUserId).first;
      final currentName = currentUser.name ?? '';
      final currentEmail = currentUser.email ?? '';
      final currentBio = currentUser.bio ?? '';

      final uploadData = {
        'name': _nameController.text.trim().isEmpty
            ? currentName
            : _nameController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? currentEmail
            : _emailController.text.toLowerCase(),
        'bio': _bioController.text.trim().isEmpty
            ? currentBio
            : _bioController.text.trim()
      };

      await _auth.updateUser(uploadData);
      showSnackBar(context, "Success update data");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: _currUserId),
        ),
      );
    } catch (e) {
      print("Error update user $e");
      showSnackBar(context, "Error update user");
    }
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Your profile"),
      ),
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

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _deviceWidth * 0.05,
                  vertical: _deviceHeight * 0.03,
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
                    SizedBox(height: 30),
                    MyTextField2(
                      controller: _nameController,
                      name: user.name,
                      prefixIcon: Icons.person,
                      inputType: TextInputType.name,
                    ),
                    SizedBox(height: 20),
                    MyTextField2(
                      controller: _emailController,
                      name: user.email,
                      prefixIcon: Icons.email_outlined,
                      inputType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),
                    MyTextField2(
                      controller: _bioController,
                      name: "Enter your bio",
                      prefixIcon: Icons.speaker_notes_outlined,
                      inputType: TextInputType.text,
                      minLine: 2,
                      maxLine: 5,
                    ),
                    SizedBox(height: 30),
                    MyButton2(
                      onPressed: handleSubmit,
                      text: "Submit",
                    ),
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
