import 'dart:math';

import 'package:flutter/material.dart';
import '../Utils/preferences.dart';

class DataPicker extends StatefulWidget {
  const DataPicker({super.key});
  @override
  DataPickerState createState() => DataPickerState();
}

class DataPickerState extends State<DataPicker> {
  Map<String, dynamic> config = {"hour": null, "minute": null};
  bool longOpen = false;

  Future<void> initConfig() async {
    for (var key in config.keys) {
      if (config[key] != null) {
        await savePreferences(key, config[key].toString());
      }
    }

    for (var key in config.keys) {
      dynamic value = await readPreferences(key);
      if (value != null || value != "") {
        config[key] = value;
      }
    }

    longOpen = bool.parse(await readPreferences("longOpen"));
    setState(() {});
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        config["hour"] = picked.hour.toString();
        config["minute"] = picked.minute.toString();
      });
      await initConfig();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: initConfig(), // 等待配置加载完成
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (config["hour"] != null && config["minute"] != null)
                    ? '已选择: ${config["hour"]}时${config["minute"]}分'
                    : '未选择时间: ',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(width: 10),
              Tooltip(
                message: "时间选择器",
                child: IconButton(
                  onPressed: () => selectTime(context),
                  icon: Icon(Icons.slow_motion_video),
                ),
              ),

              Expanded(child: SizedBox()), // 占据剩余所有空间

              Text("常开: ", style: TextStyle(fontSize: 15)),
              SizedBox(width: 10),
              Tooltip(
                message: "当开启该选项，到达时间时将常开",
                child: Switch(
                  value: longOpen,
                  onChanged: (value) async {
                    setState(() {
                      longOpen = !longOpen;
                    });
                    await savePreferences("longOpen", longOpen.toString());
                    await initConfig();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
