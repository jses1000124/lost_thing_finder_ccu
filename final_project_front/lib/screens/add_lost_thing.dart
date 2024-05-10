import 'dart:io';
import '../models/lost_thing.dart';
import 'package:flutter/material.dart';
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
  DateTime? _selectedDate;
  String? _postType;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Handle the submission, like sending data to a server or local database
    }
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 128),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '類型',
                      labelStyle: TextStyle(fontSize: 18),
                    ),
                    value: _postType,
                    items: const [
                      DropdownMenuItem(value: '遺失物', child: Text('遺失物')),
                      DropdownMenuItem(value: '待尋物', child: Text('待尋物')),
                    ],
                    hint: const Text('請選取'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _postType = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請選擇類型';
                      }
                      return null;
                    },
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _postType,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.inventory_2),
                      labelStyle: const TextStyle(fontSize: 18),
                    ),
                    style: const TextStyle(fontSize: 18),
                    controller: _titleController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '請輸入物品名稱';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          _selectedDate == null
                              ? '日期還沒選擇'
                              : formatter.format(_selectedDate!),
                          style: const TextStyle(fontSize: 16)),
                      IconButton(
                        onPressed: _presentDatePicker,
                        style: const ButtonStyle(
                            iconSize: MaterialStatePropertyAll(30)),
                        icon: const Icon(
                          Icons.calendar_month,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '地點',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                      labelStyle: TextStyle(fontSize: 18),
                    ),
                    style: const TextStyle(fontSize: 18),
                    controller: _locationController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '請輸入地點';
                      }
                      return null;
                    },
                  ),
                ),
                // Space between the text field and dropdown
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: '物品描述',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 22)),
              style: const TextStyle(fontSize: 18),
              controller: _descriptionController,
              maxLines: 6,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                const SizedBox(width: 40),
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
