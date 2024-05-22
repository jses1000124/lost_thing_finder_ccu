import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageWidget extends StatelessWidget {
  final void Function(String) onImagePicked;
  final void Function(Uint8List) onImageWebPicked;
  final Widget child;

  const UploadImageWidget(
      {super.key,
      required this.child,
      required this.onImagePicked,
      required this.onImageWebPicked});

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
              child: !kIsWeb
                  ? Column(children: <Widget>[
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
                    ])
                  : Column(
                      children: <Widget>[
                        ListTile(
                            onTap: () async {
                              Navigator.pop(context);
                              var bytes = await _showPhotoWebLibrary();
                              onImageWebPicked(bytes);
                            },
                            leading: const Icon(Icons.photo_library),
                            title: const Text("選擇照片")),
                      ],
                    ));
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

  Future<Uint8List> _showPhotoWebLibrary() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return Uint8List(0);

    return result.files.single.bytes!;
  }
}
