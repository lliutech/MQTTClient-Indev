import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../utils/toast.dart';
import '../main.dart';

class JsonConfigEditor extends StatefulWidget {
  const JsonConfigEditor({super.key});
  @override
  JsonConfigEditorState createState() => JsonConfigEditorState();
}

class JsonConfigEditorState extends State<JsonConfigEditor> {
  final _jsonController = TextEditingController();
  final DataController c = Get.find<DataController>();
  Map<String, dynamic>? _parsedConfig;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: _jsonController,
              maxLines: null,
              expands: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '在此处粘贴JSON配置',
                border: OutlineInputBorder(),
                errorText: _error.isEmpty ? null : _error,
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _parseJson, child: Text('保存配置')),
        ],
      ),
    );
  }

  void _parseJson() async {
    try {
      final parsed = jsonDecode(_jsonController.text);
      setState(() {
        _parsedConfig = parsed as Map<String, dynamic>;
        _error = '';
      });
      await c.updateConfig(
        _parsedConfig?["configName"],
        _parsedConfig?["data"],
      );
      showToast("保存成功");
    } catch (e) {
      setState(() {
        _error = 'JSON解析错误: $e';
        _parsedConfig = null;
      });
    }
  }
}
