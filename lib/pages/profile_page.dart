import 'package:chat_app/service/images_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/service/storage_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late double _deviceHeight;
  late double _deviceWidth;
  final ImagesService _imagesService = ImagesService();

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
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: _buildProfileUi(),
    );
  }

  Widget _buildProfileUi() {
    return Consumer<StorageService>(
      builder: (context, storageService, child) {
        final List<String> imgUrls = storageService.imgUrls;

        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.02),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: imgUrls.isNotEmpty
                          ? NetworkImage(imgUrls.last)
                          : AssetImage("assets/images/user1.jpg")
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
                            // await Provider.of<StorageService>(context,
                            //     listen: false)
                            //     .uploadImage(context);
                            _imagesService.uploadImageToFirestore(context);
                            // await _imagesService.uploadMetadata();
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
                  "Roby Aryanata",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Halo nama saya bla bla bla",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}
