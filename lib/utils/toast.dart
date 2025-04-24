import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:io';

void showToast(String msg) {
  Platform.isAndroid
      ? Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // 设置 Gravity 为 BOTTOM 来让 Toast 出现在屏幕底部
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      )
      : print(
        "now the platform not android, your message $msg will be destory",
      );
}
