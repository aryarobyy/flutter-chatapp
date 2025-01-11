import 'dart:io';

import 'package:chat_app/component/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService with ChangeNotifier {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _imgUrls = [];

  bool _isLoading = false;

  bool _isUploading = false;

  List<String> get imgUrls => _imgUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  Future<void> fetchImages() async {
    _isLoading = true;
    final ListResult res = await firebaseStorage.ref('images/').listAll();
    final urls =
        await Future.wait(res.items.map((ref) => ref.getDownloadURL()));
    _imgUrls = urls;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteImages(String imgUrls) async {
    try {
      _imgUrls.remove(imgUrls);
      final String path = extractPathFromUrl(imgUrls);
      await firebaseStorage.ref(path).delete();
    } catch (e) {
      print("Error deleting image : $e");
    }

    notifyListeners();
  }

  String extractPathFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String encodedPath = uri.pathSegments.last;
    return Uri.decodeComponent(encodedPath);
  }

  Future<void> uploadImage(BuildContext context) async {
    _isUploading = true;
    print("🐛 Starting image upload");
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print("No image selected");
      _isUploading = false;
      notifyListeners();
      return;
    }

    print("Image selected: ${image.path}");
    File file = File(image.path);

    if (!(await file.exists())) {
      print("File does not exist at path: ${file.path}");
      _isUploading = false;
      notifyListeners();
      return;
    }

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User is not logged in");
      }
      final String uid = currentUser.uid;

      String filePath =
          'users/$uid.${image.path.split('.').last.toLowerCase()}';
      UploadTask uploadTask = firebaseStorage.ref(filePath).putFile(file);
      print("Generated file path: $filePath");

      uploadTask.snapshotEvents.listen((snapshot) {
        print(
            "Upload progress: ${snapshot.bytesTransferred} / ${snapshot.totalBytes}");
        print("Upload state: ${snapshot.state}");
      }).onError((error) {
        print("Error during upload: $error");
      });

      TaskSnapshot snapshot = await uploadTask;
      print("Upload complete: ${snapshot.state}");

      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();
      print("Download URL: $downloadUrl");

      await _fireStore
          .collection("users")
          .doc(uid)
          .update({'image': downloadUrl});
      _imgUrls.add(downloadUrl);
      notifyListeners();
      showSnackBar(context, "Image uploaded successfully!");
    } catch (e) {
      print("Upload failed: $e");
      showSnackBar(context, "Upload failed");
    } finally {
      _isUploading = false;
      print("🐛 Image upload process completed");
      notifyListeners();
    }
  }
}
