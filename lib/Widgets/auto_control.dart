import 'package:flutter/material.dart';
import '../Utils/mqtt_mananger.dart';
import '../Utils/preferences.dart';
import 'data_picker.dart';

// import 'circue_selector.dart';

// ignore: must_be_immutable
class AutoControl extends StatefulWidget {
  final MqttManager mqttManager;
  String topic;

  AutoControl({super.key, required this.mqttManager, required this.topic});

  @override
  AutoControlState createState() => AutoControlState();
}

class AutoControlState extends State<AutoControl> {
  final TextEditingController _controller = TextEditingController();
  bool lock = false;
  Map<String, dynamic> config = {
    "hour": null,
    "minute": null,
    "longOpen": null,
    "duration": null,
  };

  Future<void> loadPreferences() async {
    for (var key in config.keys) {
      config[key] = await readPreferences(key);
    }

    lock =
        await readPreferences("autoStatue") == null
            ? false
            : bool.parse(await readPreferences("autoStatue"));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
          future: loadPreferences(),
          builder: (context, snapshot) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("自动控制", style: TextStyle(fontSize: 16)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          lock = !lock;
                          savePreferences('autoStatue', lock.toString());
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
                      DataPicker(),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  labelText: '计时时长，以分钟为单位，常开可留空',
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                      Tooltip(
                        message: "提交！",
                        child: IconButton(
                          onPressed: () async {
                            await savePreferences(
                              "duration",
                              _controller.text == "" ? "0" : _controller.text,
                            );
                            Future.delayed(Duration(milliseconds: 20));
                            Map<String, dynamic> sendMessage = {
                              "mode": 1,
                              "duration": await readPreferences("duration"),
                              "longOpen": await readPreferences("longOpen"),
                              "targetHour": await readPreferences("hour"),
                              "targetMinute": await readPreferences("minute"),
                            };

                            String message =
                                '{"mode": ${sendMessage["mode"]},"duration": ${sendMessage["duration"]},"longOpen": ${sendMessage["longOpen"]},"targetHour": ${sendMessage["targetHour"]}, "targetMinute": ${sendMessage["targetMinute"]}}';
                            widget.mqttManager.publishMessage(
                              widget.topic,
                              message,
                            );
                          },
                          icon: Icon(Icons.done),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
