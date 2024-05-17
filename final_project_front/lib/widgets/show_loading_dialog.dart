  import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 用戶不能通過點擊外部來關閉對話框
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20), // 提供一些水平空間
                Text("正在處理...", style: TextStyle(fontSize: 16)), // 顯示加載信息
              ],
            ),
          ),
        );
      },
    );
  }