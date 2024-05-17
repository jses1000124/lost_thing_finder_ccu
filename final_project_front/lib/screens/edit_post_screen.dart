import 'package:final_project/widgets/upload_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:final_project/models/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditPostPage extends StatefulWidget {
  final LostThing lostThing;
  const EditPostPage({super.key, required this.lostThing});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  late TextEditingController _locationController;
  DateTime? _selectedDate;
  int? _selectedPostType;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.lostThing.lostThingName);
    _contentController = TextEditingController(text: widget.lostThing.content);
    _locationController =
        TextEditingController(text: widget.lostThing.location);
    _selectedDate = widget.lostThing.date;
    _selectedPostType = widget.lostThing.mylosting;
    _selectedImagePath = widget.lostThing.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: now,
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _savePost() async {
    if (_formKey.currentState?.validate() ?? false) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      LostThing updatedLostThing = widget.lostThing.copyWith(
        lostThingName: _nameController.text,
        content: _contentController.text,
        location: _locationController.text,
        date: _selectedDate,
        mylosting: _selectedPostType,
        imageUrl: _selectedImagePath,
      );

      _showLoadingDialog();

      int statusCode = await postProvider.updatePost(updatedLostThing, token!);
      Navigator.of(context).pop(); // Close the loading dialog

      if (statusCode == 200) {
        _showAlertDialog('成功', '貼文已更新', success: true, popTwice: true);
      } else {
        _showAlertDialog('錯誤', '更新貼文失敗，請稍後再試');
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Users cannot dismiss by tapping outside
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20), // Add some horizontal space
                Text("正在處理...",
                    style: TextStyle(fontSize: 16)), // Display loading message
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlertDialog(String title, String message,
      {bool success = false, bool popTwice = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: success
              ? const Icon(Icons.check, color: Colors.green, size: 60)
              : const Icon(Icons.error,
                  color: Color.fromARGB(255, 255, 97, 149), size: 60),
          title: Text(title,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          content: Text(message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          actions: [
            TextButton(
              child: const Text(
                'OK',
              ),
              onPressed: () {
                if (popTwice) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯貼文'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '物品名稱',
                          labelStyle: theme.textTheme.titleMedium,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入物品名稱';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '類型',
                          labelStyle: TextStyle(fontSize: 18),
                        ),
                        value: _selectedPostType == null
                            ? null
                            : _selectedPostType == 0
                                ? '遺失物'
                                : '待尋物',
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
                            _selectedPostType = newValue == '遺失物' ? 0 : 1;
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
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: '地點',
                          labelStyle: theme.textTheme.titleMedium,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入地點';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            _selectedDate == null
                                ? '尚未選擇日期'
                                : DateFormat('yyyy/MM/dd')
                                    .format(_selectedDate!),
                            style: theme.textTheme.bodyLarge,
                          ),
                          IconButton(
                            onPressed: _presentDatePicker,
                            icon: const Icon(
                              Icons.calendar_month,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: '內容',
                    labelStyle: theme.textTheme.titleMedium,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入內容';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: UploadImageWidget(
                    onImagePicked: (path) {
                      setState(() {
                        _selectedImagePath = path;
                      });
                    },
                    child: _selectedImagePath == ''
                        ? Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.camera_alt, size: 50),
                          )
                        : Image.network(_selectedImagePath!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 60),
                    ElevatedButton(
                        onPressed: _savePost, child: const Text('儲存')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
