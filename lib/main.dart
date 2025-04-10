// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'menu/menu.dart';
import 'Utils/preferences.dart';
import 'Utils/mqtt_mananger.dart';
import 'Widgets/connect_row.dart';
import 'Widgets/manual_control.dart';
import 'Widgets/auto_control.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "This is a test application for esp8266 control",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Map<String, dynamic> config = {
    "证书路径": null,
    "服务器地址": null,
    "主题": null,
    "用户名": null,
    "密码": null,
  };
  bool show = true;

  @override
  void initState() {
    super.initState();
    //initConfig();
    mqttManager = MqttManager();
    mqttManager.client = MqttServerClient.withPort("", "", 8883);
  }

  late MqttManager mqttManager;

  Future<void> initConfig() async {
    for (var key in config.keys) {
      config[key] = await readPreferences(key);
    }
    final String? serveraddr = config["服务器地址"];

    if (serveraddr != null) {
      var res = serveraddr.toString().split(":");
      config["addr"] = res[0];
      config["port"] = int.parse(res[1]);
    }
    await Future.delayed(Duration(milliseconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Mqtt Device Controller by Liutech",
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: SideMenu(),

      body: FutureBuilder(
        future: initConfig(), // 等待配置加载完成
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 显示加载指示器
          } else if (snapshot.hasError) {
            return Center(child: Text("加载配置失败: ${snapshot.error}"));
          } else {
            return Column(
              children: [
                Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("连接选项", style: TextStyle(fontSize: 16)),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  show = !show;
                                });
                              },
                              icon:
                                  show
                                      ? Icon(Icons.expand_less)
                                      : Icon(Icons.expand_more),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: show,
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              ConnectRow(
                                mqttManager: mqttManager,
                                config: config,
                              ),
                              SizedBox(height: 10),
                              Tooltip(
                                message: "刷新配置：当配置完成后出现错误时请单击该按钮",
                                child: IconButton(
                                  onPressed: () async {
                                    await initConfig();
                                    setState(() {
                                      mqttManager.disconnect();
                                    });
                                  },
                                  icon: Icon(Icons.refresh),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                ManualControl(
                  mqttManager: mqttManager,
                  topic: config["主题"] ?? "",
                ),

                AutoControl(
                  mqttManager: mqttManager,
                  topic: config["主题"] ?? "",
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
