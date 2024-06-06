import 'dart:io';
import 'package:final_project/data/upload_image.dart';
import 'package:final_project/screens/map_select.dart';
import 'package:final_project/widgets/upload_image_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:final_project/models/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/show_alert_dialog.dart';
import '../widgets/show_loading_dialog.dart';

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
  String? _selectedLatitude;
  String? _selectedLongitude;
  String? _buildingName;
  DateTime? _selectedDate;
  int? _selectedPostType;
  String? _selectedImageUrl;
  Uint8List _imageBytes = Uint8List(0);
  String _imagepath = '';
  bool _isPickedImage = false;
  String? _posterEmail;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.lostThing.lostThingName);
    _contentController = TextEditingController(text: widget.lostThing.content);
    _selectedDate = widget.lostThing.date;
    _selectedPostType = widget.lostThing.mylosting;
    _selectedImageUrl = widget.lostThing.imageUrl;
    _selectedLatitude = widget.lostThing.latitude.toString();
    _selectedLongitude = widget.lostThing.longitude.toString();
    _buildingName = widget.lostThing.location;
    _posterEmail = widget.lostThing.postUserEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
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

  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MapSelectPage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedLatitude = result['latLng'].latitude.toString();
        _selectedLongitude = result['latLng'].longitude.toString();
        _buildingName = result['buildingName'];
      });
    }
  }

  Future<void> _savePost() async {
    if (_selectedLongitude == null ||
        _selectedLatitude == null ||
        _buildingName == null) {
      showAlertDialog('地點尚未選擇', '請選擇一個地點才能提交', context);
      return;
    }
    if (_selectedDate == null) {
      showAlertDialog('日期尚未選擇', '請選擇日期才能提交', context);
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) return; // Ensure the widget is still mounted
      String? token = prefs.getString('token');
      String upload_image = _selectedImageUrl ?? '';

      if (kIsWeb) {
        if (_imageBytes.isNotEmpty) {
          upload_image = await uploadImageWeb(
              context, 'lostThing/$_posterEmail', _imageBytes);
        }
      } else {
        if (_imagepath.isNotEmpty) {
          upload_image = await uploadImageOther(
              context, 'lostThing/$_posterEmail',
              filePath: _imagepath);
        }
      }

      // Delete the old image
      if (_imagepath.isNotEmpty) {
        if (widget.lostThing.imageUrl.isNotEmpty) {
          FirebaseStorage.instance
              .refFromURL(widget.lostThing.imageUrl)
              .delete();
        }
      }

      LostThing updatedLostThing = widget.lostThing.copyWith(
        lostThingName: _nameController.text,
        content: _contentController.text,
        location: _buildingName,
        date: _selectedDate,
        mylosting: _selectedPostType,
        latitude: double.parse(_selectedLatitude!),
        longitude: double.parse(_selectedLongitude!),
        imageUrl: upload_image,
      );
      showLoadingDialog(context);

      int statusCode = await postProvider.updatePost(updatedLostThing, token!);
      if (!mounted) return;
      Navigator.of(context).pop();

      if (statusCode == 200) {
        showAlertDialog('成功', '貼文已更新', context, success: true, popTwice: true);
      } else if (statusCode == 408) {
        showAlertDialog('錯誤', '請求超時', context);
      } else {
        showAlertDialog('錯誤', '更新貼文失敗，請稍後再試', context);
      }
    }
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
                                ? '尋獲物'
                                : '待尋物',
                        items: [
                          DropdownMenuItem(
                            value: '尋獲物',
                            child: Text(
                              '尋獲物',
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
                            _selectedPostType = newValue == '尋獲物' ? 0 : 1;
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
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
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
                            style: ButtonStyle(
                              iconSize: WidgetStateProperty.all(30),
                              foregroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                            ),
                            icon: const Icon(Icons.calendar_month),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.location_on, size: 30),
                            onPressed: _selectLocation,
                          ),
                          TextButton(
                            child: Text(
                              _buildingName ?? '尚未選擇地點',
                              style: const TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: _selectLocation,
                            style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all(
                                    Theme.of(context).colorScheme.primary)),
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
                UploadImageWidget(
                  onImagePicked: (path) {
                    setState(() {
                      _isPickedImage = true;
                      _imagepath = path;
                      _imageBytes = Uint8List(
                          0);
                    });
                  },
                  onImageWebPicked: (bytes) {
                    setState(() {
                      _isPickedImage = true;
                      _imageBytes = bytes;
                      _imagepath =
                          "";
                    });
                  },
                  child: _isPickedImage
                      ? kIsWeb
                          ? _imageBytes.isNotEmpty
                              ? Image.memory(_imageBytes, fit: BoxFit.cover)
                              : Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 50),
                                )
                          : _imagepath.isNotEmpty
                              ? Image.file(File(_imagepath), fit: BoxFit.cover)
                              : Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 50),
                                )
                      : _selectedImageUrl != null &&
                              _selectedImageUrl!.isNotEmpty
                          ? Image.network(_selectedImageUrl!, fit: BoxFit.cover)
                          : Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.camera_alt, size: 50),
                            ),
                ),
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
                      onPressed: _savePost,
                      child: const Text('儲存'),
                    ),
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
