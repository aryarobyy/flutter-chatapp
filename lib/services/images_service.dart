import 'dart:io';
import 'dart:convert';
import 'package:chat_app/component/snackbar.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

const String IMAGE_COLLECTION = "images";

class ImagesService {
  final ImagePicker _picker = ImagePicker();
  late final Cloudinary cloudinary;
  final AuthService _auth = AuthService();

  ImagesService() {
    if (dotenv.env['CLOUDINARY_CLOUD_NAME'] == null ||
        dotenv.env['CLOUDINARY_UPLOAD_PRESET'] == null) {
      throw Exception('Cloudinary environment variables not set');
    }
  }

  Future uploadImage(BuildContext context) async {
    try {
      XFile? pickedImage = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);

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

      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');

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

  Future<bool> deleteImage(BuildContext context, String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final publicId = pathSegments.last.split('.').first;

      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
      final apiKey = dotenv.env['CLOUDINARY_API_KEY']!;
      final apiSecret = dotenv.env['CLOUDINARY_API_SECRET']!;

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = generateSignature(publicId, timestamp, apiSecret);

      final deleteUri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

      final response = await http.post(
        deleteUri,
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        showSnackBar(context, "Image deleted successfully!");
        return true;
      } else {
        showSnackBar(context, "Failed to delete image.");
        print("Cloudinary delete error: ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      showSnackBar(context, "Delete failed: $e");
      print('Error deleting image: $e');
      return false;
    }
  }

  String generateSignature(String publicId, int timestamp, String apiSecret) {
    final params = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final bytes = utf8.encode(params);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }
}
