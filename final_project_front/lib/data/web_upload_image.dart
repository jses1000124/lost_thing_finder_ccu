import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:js/js_util.dart' as js_util;

class UploadImage {
  Future<String> uploadImage(
      BuildContext context, String imagePath, String saveFolder) async {
    // 使用 file_picker 选择文件

    // 获取文件
    Uint8List file = File(imagePath).readAsBytesSync();

    // 创建 Firebase Storage 参考
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

    // 将 Uint8List 转换为 JSArray
    var jsArray = js_util.jsify([file]);

    // 将文件转换为 Blob
    var blob = web.Blob(jsArray);

    // 创建上传任务
    UploadTask uploadTask = ref.putBlob(blob);

    // 显示上传进度对话框
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UploadProgressDialog(uploadTask: uploadTask);
      },
    );

    // 上传完成后获取下载 URL
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
