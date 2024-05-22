import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<String> uploadCameraImage(
    BuildContext context, String saveFolder) async {
  // 获取本地文件
  ImagePicker picker = ImagePicker();
  XFile? image = await picker.pickImage(source: ImageSource.camera);
  File file = File(image!.path);
  if (await file.exists()) {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

    UploadTask uploadTask = ref.putFile(file);
    if (!context.mounted) return '';
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
  } else {
    throw Exception("File does not exist");
  }
}

Future<String> uploadImageWeb(
    BuildContext context, String saveFolder, Uint8List file) async {
  // 获取文件

  // 创建 Firebase Storage 参考
  Reference ref = FirebaseStorage.instance
      .ref()
      .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

  // 创建上传任务
  UploadTask uploadTask = ref.putData(file);
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

Future<String> uploadImageOther(BuildContext context, String saveFolder,
    {String filePath = ''}) async {
  // 获取本地文件
  File? file;
  if (filePath == '') {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    file = File(image!.path);
    if (!context.mounted) return '';
  } else {
    file = File(filePath);
  }

  if (await file.exists()) {
    // 创建 Firebase Storage 参考
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

    // 创建上传任务
    UploadTask uploadTask = ref.putFile(file);
    if (!context.mounted) return '';
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
  } else {
    throw Exception("File does not exist");
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
