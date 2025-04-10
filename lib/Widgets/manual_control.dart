import 'package:flutter/material.dart';
import '../Utils/mqtt_mananger.dart';
import '../Utils/preferences.dart';

// ignore: must_be_immutable
class ManualControl extends StatefulWidget {
  final MqttManager mqttManager;
  String topic;

  ManualControl({super.key, required this.mqttManager, required this.topic});

  @override
  ManualControlState createState() => ManualControlState();
}

class ManualControlState extends State<ManualControl> {
  bool lock = false;
  bool manulaControl = false;

  Future<void> loadPreferences() async {
    lock =
        await readPreferences("manualStatue") == null
            ? false
            : bool.parse(await readPreferences("manualStatue"));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
          future: loadPreferences(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("加载配置失败: ${snapshot.error}"));
            } else {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("手动控制", style: TextStyle(fontSize: 16)),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            lock = !lock;
                            savePreferences("manualStatue", lock.toString());
                          });
                        },
                        icon:
                            lock
                                ? Icon(Icons.expand_less)
                                : Icon(Icons.expand_more),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: lock,
                    child: Column(
                      children: [
                        Divider(),
                        Text(manulaControl == true ? "开" : "关"),
                        Switch(
                          value: manulaControl,
                          onChanged: (value) {
                            setState(() {
                              manulaControl = value;
                              final String message =
                                  '{"mode": 2, "handle": $manulaControl}';
                              widget.mqttManager.publishMessage(
                                widget.topic,
                                message,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
