import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CloudService();

  Future<String?> pickImageAndUpload(String uid) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        print("No file selected");
        return null;
      }

      File file = File(pickedFile.path);

      Reference ref = _storage.ref().child('images/users/$uid/profile.${pickedFile.path.split('.').last}');
      UploadTask task = ref.putFile(file);

      return await task.then((res) => res.ref.getDownloadURL());
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }
}
