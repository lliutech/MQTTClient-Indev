import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import '../utils/toast.dart';
import '../main.dart';
import '../templates/config_template.dart';

// ignore: must_be_immutable
class StepConfig extends StatefulWidget {
  const StepConfig({super.key});

  @override
  StepConfigState createState() => StepConfigState();
}

class StepConfigState extends State<StepConfig> {
  final _formKey = GlobalKey<FormState>();
  final DataController c = Get.find<DataController>();
  String server = '';
  String username = '';
  String password = '';
  String topic = '';
  String? keyPath;
  late String configName;
  int port = 8883;
  bool enableSSL = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: '配置名称'),
              validator: (value) => value!.isEmpty ? '必填项' : null,
              onSaved: (value) => configName = value!,
            ),

            TextFormField(
              decoration: InputDecoration(labelText: '服务器地址'),
              validator: (value) => value!.isEmpty ? '必填项' : null,
              onSaved: (value) => server = value!,
            ),

            TextFormField(
              decoration: InputDecoration(labelText: '端口号'),
              initialValue: '8883',
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? '必填项' : null,
              onSaved: (value) => port = int.parse(value!),
            ),

            TextFormField(
              decoration: InputDecoration(labelText: '用户名'),
              // validator: (value) => value!.isEmpty ? '必填项' : null,
              onSaved: (value) => username = value!,
            ),

            TextFormField(
              decoration: InputDecoration(labelText: '密码'),
              // validator: (value) => value!.isEmpty ? '必填项' : null,
              onSaved: (value) => password = value!,
            ),

            TextFormField(
              decoration: InputDecoration(labelText: '主题'),
              // validator: (value) => value!.isEmpty ? '必填项' : null,
              onSaved: (value) => topic = value!,
            ),

            SwitchListTile(
              title: Text('启用SSL'),
              value: enableSSL,
              onChanged: (value) async {
                if (value) {
                  keyPath = await pickCertificate();
                  if (keyPath == null) {
                    showToast("警告：获取证书路径错误，请重新选择");
                  } else {
                    setState(() {
                      enableSSL = value;
                    });
                  }
                } else {
                  setState(() {
                    enableSSL = value;
                  });
                }
              },
            ),
            ElevatedButton(onPressed: _saveConfig, child: Text('保存配置')),
          ],
        ),
      ),
    );
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final Map config =
          ConnectConfig(
            server: server,
            port: port,
            topic: topic,
            keyPath: keyPath,
            userName: username,
            passWord: password,
          ).tMap();
      print(config);
      await c.updateConfig(configName, config);
      showToast("添加成功");
    }
  }

  Future<String?> pickCertificate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem', 'crt'], // 只允许选择证书文件
    );

    if (result != null) {
      String? path = result.files.first.path;
      return path;
    }
    return null;
  }
}
