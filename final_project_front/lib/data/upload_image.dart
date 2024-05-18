import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadImage {
  Future<String> uploadImage(
      BuildContext context, String imagePath, String saveFolder) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

    UploadTask uploadTask = ref.putFile(File(imagePath));

    // Show upload progress dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UploadProgressDialog(uploadTask: uploadTask);
      },
    );

    // Get download URL once the upload is complete
    String imageUrl = await (await uploadTask).ref.getDownloadURL();
    debugPrint('File uploaded to $imageUrl');
    return imageUrl;
  }
}

class UploadProgressDialog extends StatelessWidget {
  final UploadTask uploadTask;

  const UploadProgressDialog({super.key, required this.uploadTask});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: StreamBuilder<TaskSnapshot>(
        stream: uploadTask.snapshotEvents,
        builder: (BuildContext context, AsyncSnapshot<TaskSnapshot> snapshot) {
          if (snapshot.hasData) {
            final TaskSnapshot taskSnapshot = snapshot.data!;
            final double progress =
                taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;

            if (taskSnapshot.state == TaskState.success) {
              Navigator.of(context).pop();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(value: progress),
                const SizedBox(height: 16.0),
                Text('${(progress * 100).toStringAsFixed(2)} %'),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
