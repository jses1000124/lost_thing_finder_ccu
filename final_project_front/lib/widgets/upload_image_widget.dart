import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageWidget extends StatelessWidget {
  final void Function(String) onImagePicked;
  final Widget child;

  const UploadImageWidget(
      {super.key, required this.child, required this.onImagePicked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showOptions(context);
      },
      child: child,
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
              height: 200,
              child: Column(children: <Widget>[
                ListTile(
                    onTap: () async {
                      Navigator.pop(context);
                      var path = await _showCameraLibrary();
                      onImagePicked(path);
                    },
                    leading: const Icon(Icons.photo_camera),
                    title: const Text("拍攝照片")),
                ListTile(
                    onTap: () async {
                      Navigator.pop(context);
                      var path = await _showPhotoLibrary();
                      onImagePicked(path);
                    },
                    leading: const Icon(Icons.photo_library),
                    title: const Text("選擇照片"))
              ]));
        });
  }

  Future<String> _showCameraLibrary() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);

    return image!.path;
  }

  Future<String> _showPhotoLibrary() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    return image!.path;
  }
}
