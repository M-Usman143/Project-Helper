import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<String>> uploadImages(String userId, String adId, List<File> images) async {
    List<String> imageUrls = [];

    for (var i = 0; i < images.length; i++) {
      String fileName = "image_$i.jpg";
      Reference ref = _storage.ref().child("adImages/$userId/$adId/$fileName");

      UploadTask uploadTask = ref.putFile(images[i]);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }
}
