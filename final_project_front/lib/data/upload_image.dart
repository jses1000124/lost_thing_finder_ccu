import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<XFile?> compressImage(File file) async {
  final dir = await getTemporaryDirectory();
  final targetPath = path.join(dir.absolute.path, "temp.jpg");

  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    format: CompressFormat.jpeg,
    targetPath,
    quality: 80,
  );

  return result;
}

Future<Uint8List?> compressWebImage(Uint8List file) async {
  try {
    final result = await FlutterImageCompress.compressWithList(
      file,
      quality: 80, // Adjust the quality as needed
    );
    return Uint8List.fromList(result);
  } catch (e) {
    debugPrint('Error compressing image: $e');
    return null;
  }
}

Future<String> uploadImageWeb(
    BuildContext context, String saveFolder, Uint8List file) async {
  // Create Firebase Storage reference
  Reference ref = FirebaseStorage.instance
      .ref()
      .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

  Uint8List? compressedImage = await compressWebImage(file);

  // Check if compression was successful
  if (compressedImage == null) {
    throw Exception('Image compression failed');
  }

  // Create upload task
  UploadTask uploadTask = ref.putData(compressedImage);

  // Show upload progress dialog
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return UploadProgressDialog(uploadTask: uploadTask);
    },
  );

  // Get download URL after upload is complete
  String imageUrl = await (await uploadTask).ref.getDownloadURL();
  debugPrint('File uploaded to $imageUrl');
  return imageUrl;
}

Future<String> uploadCameraImage(
    BuildContext context, String saveFolder) async {
  // 获取本地文件
  ImagePicker picker = ImagePicker();
  XFile? image = await picker.pickImage(source: ImageSource.camera);
  File file = File(image!.path);

  File? compressedImage = File((await compressImage(file))!.path);

  if (await compressedImage.exists()) {
    // 创建 Firebase Storage 参考
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

    // 创建上传任务
    UploadTask uploadTask = ref.putFile(compressedImage);
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
    debugPrint('File uploaded');
    return imageUrl;
  } else {
    throw Exception("File does not exist");
  }
}

// Future<String> uploadImageWeb(
//     BuildContext context, String saveFolder, Uint8List file) async {
//   // 获取文件

//   // 创建 Firebase Storage 参考
//   Reference ref = FirebaseStorage.instance
//       .ref()
//       .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

//   Uint8List? compressedImage = await compressWebImage(file);
//   if (compressedImage == null) {
//     throw Exception('Image compression failed');
//   }
//   // 创建上传任务
//   UploadTask uploadTask = ref.putData(compressedImage!);
//   // 显示上传进度对话框
//   await showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return UploadProgressDialog(uploadTask: uploadTask);
//     },
//   );

//   // 上传完成后获取下载 URL
//   String imageUrl = await (await uploadTask).ref.getDownloadURL();
//   debugPrint('File uploaded to $imageUrl');
//   return imageUrl;
// }

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

  File? compressedImage = File((await compressImage(file))!.path);

  if (await compressedImage.exists()) {
    // 创建 Firebase Storage 参考
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('$saveFolder/${DateTime.now().millisecondsSinceEpoch}');

    // 创建上传任务
    UploadTask uploadTask = ref.putFile(compressedImage);
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
    debugPrint('File uploaded');
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
