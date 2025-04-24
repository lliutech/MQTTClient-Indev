import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'config_parse.dart';
import 'config_edit.dart';
import 'package:flutter/services.dart';
import '../utils/toast.dart';
import '../main.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  ConfigPageState createState() => ConfigPageState();
}

class ConfigPageState extends State<ConfigPage> {
  final textStyle = TextStyle(fontSize: 16);
  final DataController c = Get.find<DataController>();

  ListTile listViewBuilder(
    String title,
    String subtitle,
    IconData icon,
    Map data,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
      leading: Icon(icon, color: Colors.blue[500], size: 30),
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: jsonEncode(data)));
        showToast("已作为JSON配置复制到剪切板");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("配置"),
        actions: [
          IconButton(
            onPressed: () {
              //showToast("正在跳转添加，请稍后......");
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ConfigParse()))
                  .then((v) {
                    setState(() {});
                  });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body:
          c.configNames.value.isEmpty == true
              ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("无配置，请点击右上角", style: textStyle),
                    Icon(Icons.add),
                    Text("创建一个...", style: textStyle),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: c.configNum.value,
                itemBuilder: (BuildContext context, int index) {
                  print(index);
                  final key = c.configNames.value[index];

                  final name = c.connectConfig.value[key]["server"];
                  final port = c.connectConfig.value[key]["port"];
                  final topic = c.connectConfig.value[key]["topic"];
                  final keyPath = c.connectConfig.value[key]["keypath"];

                  return Dismissible(
                    key: Key(key),
                    background: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(Icons.edit, color: Colors.white),
                    ),

                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),

                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: listViewBuilder(
                          key,
                          "地址：$name: $port\n主题: ${topic == "" ? "空" : topic}\n启用SSL: ${keyPath == null ? "否" : "是"}",
                          Icons.settings,
                          {
                            "configName": key,
                            "data": c.connectConfig.value[key],
                          },
                        ),
                      ),
                    ),

                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder:
                                    (context) => EditConfig(
                                      config: c.connectConfig.value[key],
                                      keys: key,
                                    ),
                              ),
                            )
                            .then((v) {
                              setState(() {});
                            });
                        return false;
                      } else if (direction == DismissDirection.endToStart) {
                        c.dropConfig(key);
                        return true;
                      } else {
                        return false;
                      }
                    },
                  );
                },
              ),
    );
  }
}
