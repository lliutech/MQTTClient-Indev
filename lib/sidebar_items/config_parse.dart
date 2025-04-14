import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'edit_steps.dart';
import 'edit_json.dart';

enum ConfigInputMode { steps, json }

class ConfigParse extends StatefulWidget {
  const ConfigParse({super.key});

  @override
  ConfigParseState createState() => ConfigParseState();
}

class ConfigParseState extends State<ConfigParse> {
  ConfigInputMode _mode = ConfigInputMode.steps;
  late Box<Map<dynamic, dynamic>> settingConfig;
  final textStyle = TextStyle(fontSize: 16);
  Future<void>? _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = initializedStart(); // 初始化时创建 Future
  }

  Future<void> initializedStart() async {
    Directory directory = (await getExternalStorageDirectory())!;
    String dbPath = "${directory.path}/Hive";
    settingConfig = await Hive.openBox<Map>("settingConfig", path: dbPath);
    Future.delayed(Duration(milliseconds: 10000));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("配置编辑器")),
      body: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: SegmentedButton<ConfigInputMode>(
                    selected: {_mode},
                    segments: [
                      const ButtonSegment(
                        value: ConfigInputMode.steps,
                        label: Text("分步配置"),
                      ),

                      const ButtonSegment(
                        value: ConfigInputMode.json,
                        label: Text("解析Json"),
                      ),
                    ],
                    onSelectionChanged: (newSelected) {
                      setState(() {
                        _mode = newSelected.first;
                      });
                    },
                  ),
                ),

                Expanded(
                  child:
                      _mode == ConfigInputMode.json
                          ? JsonConfigEditor()
                          : StepConfig(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
