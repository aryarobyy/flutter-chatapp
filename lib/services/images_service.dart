import 'dart:io';
import 'dart:convert';
import 'package:chat_app/component/snackbar.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;


const String IMAGE_COLLECTION = "images";

class ImagesService {
  final ImagePicker _picker = ImagePicker();
  late final Cloudinary cloudinary;
  final AuthMethod _auth = AuthMethod();

  ImagesService() {
    if (dotenv.env['CLOUDINARY_CLOUD_NAME'] == null ||
        dotenv.env['CLOUDINARY_UPLOAD_PRESET'] == null) {
      throw Exception('Cloudinary environment variables not set');
    }
  }

  Future uploadImage(BuildContext context) async {
    try {
      XFile? pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
        imageQuality: 70
      );

      if (pickedImage == null) {
        showSnackBar(context, "No image selected.");
        return;
      }

      File imageFile = File(pickedImage.path);
      if (!await imageFile.exists()) {
        showSnackBar(context, "File does not exist.");
        return;
      }

      final uuid = Uuid().v4();
      late final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
      late final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/auto/upload'
      );

      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = uuid
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            filename: '$uuid.jpg',
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseData);
        final imageUrl = jsonResponse['secure_url'] as String;

        // final updatedData ={
        //   'image' : imageUrl,
        // };
        // final res = _auth.updateUser(updatedData);
        // print("Response: $res");

        showSnackBar(context, "Image uploaded successfully!");
        print("Uploaded Image URL: $imageUrl");
        return imageUrl;
      } else {
        showSnackBar(context, "Image upload failed.");
        print("Cloudinary upload error: ${response.reasonPhrase}");
      }
    } catch (e) {
      showSnackBar(context, "Upload failed: $e");
      print('Error uploading image: $e');
    }
  }

}