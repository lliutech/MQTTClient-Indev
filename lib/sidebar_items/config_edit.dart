import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/toast.dart';
import '../main.dart';
import '../templates/config_template.dart';

// ignore: must_be_immutable
class EditConfig extends StatefulWidget {
  Map<dynamic, dynamic>? config;
  String keys;
  EditConfig({super.key, required this.config, required this.keys});

  @override
  EditConfigState createState() => EditConfigState();
}

class EditConfigState extends State<EditConfig> {
  final _formKey = GlobalKey<FormState>();
  final DataController c = Get.find<DataController>();
  dynamic configName;
  dynamic server;
  dynamic username;
  dynamic password;
  dynamic topic;
  dynamic keyPath;
  dynamic port;
  bool enableSSL = false;

  @override
  void initState() {
    super.initState();
    configName = widget.keys;
    server = c.connectConfig.value[widget.keys]["server"];
    username = c.connectConfig.value[widget.keys]["username"];
    password = c.connectConfig.value[widget.keys]["password"];
    topic = c.connectConfig.value[widget.keys]["topic"];
    keyPath = c.connectConfig.value[widget.keys]["keyPath"];
    port = c.connectConfig.value[widget.keys]["port"];
    enableSSL = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("编辑配置"),
        actions: [
          IconButton(onPressed: _saveConfig, icon: Icon(Icons.save)),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: '配置名称'),
                initialValue: widget.keys,
                validator: (value) => value!.isEmpty ? '必填项' : null,
                onSaved: (value) => configName = value!,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: '服务器地址'),
                initialValue: server,
                validator: (value) => value!.isEmpty ? '必填项' : null,
                onSaved: (value) => server = value!,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: '端口号'),
                initialValue: '$port',
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? '必填项' : null,
                onSaved: (value) => port = int.parse(value!),
              ),

              TextFormField(
                decoration: InputDecoration(labelText: '用户名'),
                initialValue: username,
                onSaved: (value) => username = value!,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: '密码'),
                initialValue: password,
                onSaved: (value) => password = value!,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: '主题'),
                initialValue: topic,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final config =
          ConnectConfig(
            server: server,
            port: port,
            topic: topic,
            keyPath: keyPath,
            userName: username,
            passWord: password,
          ).tMap();

      await c.updateConfig(configName, config);
      showToast("保存成功");
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
