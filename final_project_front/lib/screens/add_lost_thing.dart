import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../widgets/upload_image_widget.dart';

class AddLostThing extends StatefulWidget {
  const AddLostThing({super.key});

  @override
  State<AddLostThing> createState() => _AddLostThingState();
}

class _AddLostThingState extends State<AddLostThing> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _path = "";

  void _submitForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    // Here you might add code to handle the submission, like sending data to a server or local database
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 128, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: '遺失物',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
                labelStyle: TextStyle(fontSize: 18),
              ),
              style: const TextStyle(fontSize: 18, color: Colors.white),
              controller: _titleController,
              validator: (value) {
                if (value!.isEmpty) {
                  return '請輸入物品名稱';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '地點',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
                labelStyle: TextStyle(fontSize: 18),
              ),
              style: const TextStyle(fontSize: 18, color: Colors.white),
              controller: _locationController,
              validator: (value) {
                if (value!.isEmpty) {
                  return '請輸入地點';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: '物品描述',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 22)),
              style: const TextStyle(fontSize: 18, color: Colors.white),
              controller: _descriptionController,
              maxLines: 6,
              validator: (value) {
                if (value!.isEmpty) {
                  return '請輸入物品描述';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            UploadImageWidget(
              onImagePicked: (path) {
                setState(() {
                  _path = path;
                });
              },
              child: _path.isEmpty
                  ? Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.camera_alt, size: 50),
                    )
                  : Image.file(File(_path), fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text(
                    '上傳',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text(
                      '取消',
                      style: TextStyle(fontSize: 18),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
