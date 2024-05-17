import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../widgets/show_loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/widgets/show_alert_dialog.dart';
import '../models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import '../widgets/upload_image_widget.dart';
import 'package:http/http.dart' as http;

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
  String _imagepath = "";
  DateTime? _selectedDate;
  String? _postType;

  void _submitForm() {
    if (_selectedDate == null) {
      showAlertDialog('日期尚未選擇', '請選擇一個日期才能提交', context);
      return;
    }
    if (_formKey.currentState!.validate()) {
      if (_imagepath.isNotEmpty) {
        showLoadingDialog(context);

        uploadImage();
      } else {
        showLoadingDialog(context);

        postDetails(null);
      }
    }
  }

  Future<void> uploadImage() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}');

    // 上傳文件
    UploadTask uploadTask = ref.putFile(File(_imagepath));

    // 可選：如果你需要獲取文件上傳進度
    // uploadTask.snapshotEvents.listen((event) {
    //   print('Task state: ${event.state}');
    //   print('Progress: ${(event.bytesTransferred / event.totalBytes) * 100} %');
    // });
    String imageUrl = await (await uploadTask).ref.getDownloadURL();
    debugPrint('File uploaded to $imageUrl');
    postDetails(imageUrl);
  }

  void postDetails(String? imageUrl) async {
    final Uri apiUrl = Uri.parse('$basedApiUrl/post');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String email = prefs.getString('email') ?? '';
    final String token = prefs.getString('token') ?? '';

    try {
      final response = await http.post(
        apiUrl,
        body: jsonEncode({
          'title': _titleController.text,
          'context': _descriptionController.text,
          'location': _locationController.text,
          'date': _selectedDate!.toIso8601String(),
          'image': imageUrl,
          'my_losting': _postType == '遺失物' ? '0' : '1',
          'author_email': email,
          'token': token,
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        Navigator.of(context).pop();
        showAlertDialog('成功', '上傳成功', context,
            isRegister: true, popTwice: true);
      } else {
        Navigator.of(context).pop();
        final responseData = jsonDecode(response.body);
        String errorMessage = '上傳失敗: ${responseData['message']}';
        showAlertDialog('失敗', errorMessage, context);
      }
    } on TimeoutException catch (_) {
      Navigator.of(context).pop();
      showAlertDialog('錯誤', '連線超時', context);
    } catch (e) {
      Navigator.of(context).pop();
      showAlertDialog('錯誤', '發生未知錯誤: $e', context);
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                        items: [
                          DropdownMenuItem(
                            value: '遺失物',
                            child: Text(
                              '遺失物',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: '待尋物',
                            child: Text(
                              '待尋物',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                        hint: const Text('請選取'),
                        onChanged: (String? newValue) {
                          setState(() {
                            _postType = newValue;
                            // Trigger form field validation to refresh and remove the error message
                            _formKey.currentState?.validate();
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
                      _imagepath = path;
                    });
                  },
                  child: _imagepath.isEmpty
                      ? Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.camera_alt, size: 50),
                        )
                      : Image.file(File(_imagepath), fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text(
                        '上傳',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
