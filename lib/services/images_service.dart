import 'dart:io';
import 'package:chat_app/component/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

const String IMAGE_COLLECTION = "images";

class ImagesService {
  final ImagePicker _picker = ImagePicker();

  Future<void> uploadImageToFirestore(BuildContext context) async {
    try {
      // Pick image from gallery
      XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) {
        showSnackBar(context, "No image selected.");
        return;
      }

      File imageFile = File(pickedImage.path);

      if (!await imageFile.exists()) {
        showSnackBar(context, "File does not exist.");
        return;
      }

      // Generate a unique ID for the image
      final uuid = Uuid().v4();

      // Reference to Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("$IMAGE_COLLECTION/$uuid.jpg");

      // Upload image to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Await upload completion
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

      // Check if upload is successful
      if (snapshot.state == TaskState.success) {
        // Get the download URL
        String imageUrl = await storageReference.getDownloadURL();

        // Save image metadata to Firestore
        await FirebaseFirestore.instance.collection(IMAGE_COLLECTION).add({
          'url': imageUrl,
          'uploaded_at': DateTime.now().toUtc().toIso8601String(),
        });

        // Notify user and log success
        showSnackBar(context, "Image uploaded successfully!");
        print('Image uploaded successfully! URL: $imageUrl');
      } else {
        showSnackBar(context, "Upload failed. Please try again.");
        print('Upload task failed.');
      }
    } catch (e) {
      // Handle errors
      showSnackBar(context, "Upload failed: $e");
      print('Error uploading image: $e');
    }
  }
}
