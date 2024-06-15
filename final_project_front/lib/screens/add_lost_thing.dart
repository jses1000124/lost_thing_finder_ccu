import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:final_project/data/upload_image.dart';
import '../widgets/show_loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/widgets/show_alert_dialog.dart';
import '../models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../widgets/upload_image_widget.dart';
import 'package:http/http.dart' as http;
import '../screens/map_select.dart';

class AddLostThing extends StatefulWidget {
  const AddLostThing({super.key});

  @override
  State<AddLostThing> createState() => _AddLostThingState();
}

class _AddLostThingState extends State<AddLostThing> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  String _imagepath = "";
  DateTime? _selectedDate = formatter.parse(formatter.format(DateTime.now()));
  String? _postType;
  Uint8List _imageBytes = Uint8List(0);
  String? _selectedLongitude;
  String? _selectedLatitude;
  String? _buildingName;

  void _submitForm() async {
    if (_selectedDate == null) {
      showAlertDialog('日期尚未選擇', '請選擇一個日期才能提交', context);
      return;
    }
    if (_selectedLongitude == null ||
        _selectedLatitude == null ||
        _buildingName == null) {
      showAlertDialog('地點尚未選擇', '請選擇一個地點才能提交', context);
      return;
    }
    if (_formKey.currentState!.validate()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String email = prefs.getString('email') ?? '';
      if (_imagepath.isNotEmpty || _imageBytes.isNotEmpty) {
        showLoadingDialog(context);
        if (kIsWeb) {
          debugPrint('Uploading image from web');
          uploadImageWeb(context, 'lostThing/$email', _imageBytes)
              .then((imageUrl) {
            postDetails(imageUrl);
          }).catchError((error) {
            Navigator.of(context).pop();
            showAlertDialog('上傳失敗', '圖片上傳失敗，請重試', context);
          });
        } else {
          debugPrint('Uploading image from device');
          uploadImageOther(context, 'lostThing/$email', filePath: _imagepath)
              .then((imageUrl) {
            postDetails(imageUrl);
          }).catchError((error) {
            Navigator.of(context).pop();
            showAlertDialog('上傳失敗', '圖片上傳失敗，請重試', context);
          });
        }
      } else {
        debugPrint('Uploading no image');
        showLoadingDialog(context);
        postDetails(null);
      }
    }
    debugPrint('returning from submitForm');
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
          'location': _buildingName,
          'date': _selectedDate!.toIso8601String(),
          'image': imageUrl,
          'my_losting': _postType == '尋獲物' ? '0' : '1',
          'author_email': email,
          'token': token,
          'latitude': _selectedLatitude,
          'longitude': _selectedLongitude,
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.of(context).pop();
        showAlertDialog('成功', '上傳成功', context, success: true, popTwice: true);
      } else {
        Navigator.of(context).pop();
        final responseData = jsonDecode(response.body);
        String errorMessage = '上傳失敗: ${responseData['message']}';
        showAlertDialog('失敗', errorMessage, context);
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showAlertDialog('錯誤', '連線超時', context);
    } catch (e) {
      if (!mounted) return;
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
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
                            _postType = newValue;
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
                        focusNode: _titleFocusNode,
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
                            style: TextStyle(
                              fontSize: 16,
                              // color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: _presentDatePicker,
                            icon: const Icon(Icons.calendar_month, size: 30),
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                            ),
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
                          Flexible(
                            child: TextButton(
                              child: Text(
                                _buildingName ?? '尚未選擇地點',
                                style: const TextStyle(fontSize: 18),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: _selectLocation,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  focusNode: _descriptionFocusNode,
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
                      _imageBytes = Uint8List(
                          0); 
                    });
                  },
                  onImageWebPicked: (bytes) {
                    setState(() {
                      _imageBytes = bytes;
                      _imagepath =
                          ""; 
                    });
                  },
                  child: _imagepath.isEmpty && _imageBytes.isEmpty
                      ? Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.camera_alt, size: 50),
                        )
                      : kIsWeb
                          ? Image.memory(_imageBytes, fit: BoxFit.cover)
                          : Image.file(File(_imagepath), fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
