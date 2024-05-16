import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadImage {
  Future<String> uploadImage(String imagepath,String saveFolder) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

    // 上傳文件
    UploadTask uploadTask = ref.putFile(File(imagepath));

    // 可選：如果你需要獲取文件上傳進度
    // uploadTask.snapshotEvents.listen((event) {
    //   print('Task state: ${event.state}');
    //   print('Progress: ${(event.bytesTransferred / event.totalBytes) * 100} %');
    // });
    String imageUrl = await (await uploadTask).ref.getDownloadURL();
    debugPrint('File uploaded to $imageUrl');
    return imageUrl;
  }
}
