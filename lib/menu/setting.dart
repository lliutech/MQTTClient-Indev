import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../Utils/preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  Map<String, String?> config = {
    "证书路径": null,
    "服务器地址": null,
    "主题": null,
    "用户名": null,
    "密码": null,
  };

  bool inputVisable1 = false;
  bool inputVisable2 = false;
  bool inputVisable3 = false;
  bool inputVisable4 = false;

  final TextEditingController _controller = TextEditingController();

  Future<void> loadConfig() async {
    await Future.delayed(Duration(microseconds: 10));
    config.forEach((k, v) async {
      config[k] = await readPreferences(k);
    });
    setState(() {});
  }

  // 在加载设置界面时先加载用户配置
  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  Future<void> pickCertificate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem', 'crt'], // 只允许选择证书文件
    );

    if (result != null) {
      String? path = result.files.first.path;
      if (path != null) {
        config["证书路径"] = path;
        savePreferences("证书路径", config["证书路径"].toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("设置")),
      body: Card(
        child: Column(
          children: [
            // 服务器地址
            ListTile(
              onTap: () async {
                setState(() {
                  inputVisable1 = !inputVisable1;
                });
              },

              title: const Text(
                '服务器地址',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              subtitle: Text(
                config["服务器地址"] == null || config["服务器地址"] == ""
                    ? "未配置"
                    : config["服务器地址"].toString(),
              ),

              leading: Icon(Icons.public, color: Colors.blue[500]),
            ),

            Visibility(
              visible: inputVisable1,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '请输入内容',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          config["服务器地址"] = value;
                          savePreferences("服务器地址", value);
                        });
                      },
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(10),
                    child: IconButton(
                      onPressed: () async {
                        await savePreferences("服务器地址", _controller.text);
                        _controller.clear();
                        await loadConfig();
                        inputVisable1 = !inputVisable1;
                      },
                      icon: Icon(Icons.done),
                    ),
                  ),
                ],
              ),
            ),

            // 主题
            ListTile(
              onTap: () async {
                setState(() {
                  inputVisable2 = !inputVisable2;
                });
              },

              title: const Text(
                '主题',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              subtitle: Text(
                config["主题"] == null || config["主题"] == ""
                    ? "未配置"
                    : config["主题"].toString(),
              ),

              leading: Icon(Icons.message_outlined, color: Colors.blue[500]),
            ),

            Visibility(
              visible: inputVisable2,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '请输入内容',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          config["主题"] = value;
                          savePreferences("主题", value);
                        });
                      },
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(10),
                    child: IconButton(
                      onPressed: () async {
                        await savePreferences("主题", _controller.text);
                        _controller.clear();
                        await loadConfig();
                        inputVisable2 = !inputVisable2;
                      },
                      icon: Icon(Icons.done),
                    ),
                  ),
                ],
              ),
            ),

            // 用户名
            ListTile(
              onTap: () async {
                setState(() {
                  inputVisable3 = !inputVisable3;
                });
              },

              title: const Text(
                '用户名',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              subtitle: Text(
                config["用户名"] == null || config["用户名"] == ""
                    ? "未配置"
                    : config["用户名"].toString(),
              ),

              leading: Icon(Icons.account_box, color: Colors.blue[500]),
            ),

            Visibility(
              visible: inputVisable3,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '请输入内容',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          config["用户名"] = value;
                          savePreferences("用户名", value);
                        });
                      },
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(10),
                    child: IconButton(
                      onPressed: () async {
                        await savePreferences("用户名", _controller.text);
                        _controller.clear();
                        await loadConfig();
                        inputVisable3 = !inputVisable3;
                      },
                      icon: Icon(Icons.done),
                    ),
                  ),
                ],
              ),
            ),

            // 密码
            ListTile(
              onTap: () async {
                setState(() {
                  inputVisable4 = !inputVisable4;
                });
              },

              title: const Text(
                '密码',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              subtitle: Text(
                config["密码"] == null || config["密码"] == ""
                    ? "未配置"
                    : config["密码"].toString(),
              ),

              leading: Icon(Icons.key, color: Colors.blue[500]),
            ),

            Visibility(
              visible: inputVisable4,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '请输入内容',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          config["密码"] = value;
                          savePreferences("密码", value);
                        });
                      },
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(10),
                    child: IconButton(
                      onPressed: () async {
                        await savePreferences("密码", _controller.text);
                        _controller.clear();
                        await loadConfig();
                        inputVisable4 = !inputVisable4;
                      },
                      icon: Icon(Icons.done),
                    ),
                  ),
                ],
              ),
            ),

            // 证书选择
            ListTile(
              onTap: () async {
                await pickCertificate();
                setState(() {
                  loadConfig();
                });
              },
              onLongPress: () async {
                await removePreferences("证书路径");
                setState(() {
                  loadConfig();
                });
              },

              title: const Text(
                '选择证书',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                config["证书路径"] == null
                    ? "未选择"
                    : '已选择: ${config["证书路径"].toString()}',
              ),
              leading: Icon(Icons.lock, color: Colors.blue[500]),
            ),
          ],
        ),
      ),
    );
  }
}
