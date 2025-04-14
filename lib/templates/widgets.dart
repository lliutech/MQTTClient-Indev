// ignore_for_file: must_be_immutable
import 'package:esp8266_controller/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main.dart';
import '../utils/data_picker.dart';

class CenterStyle extends StatelessWidget {
  String name;
  CenterStyle({super.key, required this.name});
  final DataController c = Get.find<DataController>();

  Color functionColor = Color.fromARGB(255, 188, 248, 241);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color:
            c.devices.value[name]["deviceConfig"]["functions"] == true
                ? Color.fromARGB(65, 156, 188, 137)
                : Color.fromARGB(41, 152, 91, 96),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name),
          SizedBox(height: 5),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: c.devices.value[name]["deviceConfig"]["targetStatue"],
              onChanged: (v) {
                c.devices.value[name]["deviceConfig"]["targetStatue"] = v;
                c.updateDevice(name, c.devices.value[name]);
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: "删除设备",
                child: IconButton(
                  onPressed: () {
                    c.dropDevice(name);
                  },
                  icon: Icon(Icons.delete),
                ),
              ),

              c.devices.value[name]["deviceConfig"]["functions"] == true
                  ? Tooltip(
                    message: "启动定时",
                    child: IconButton(
                      onPressed: () {
                        showToast("已启动定时配置");
                      },
                      icon: Icon(Icons.send),
                    ),
                  )
                  : SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}

class InitPageTaplessGrid extends StatelessWidget {
  String name;
  InitPageTaplessGrid({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return CenterStyle(name: name);
  }
}

class InitPageTapableGrid extends StatelessWidget {
  String name;
  InitPageTapableGrid({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CenterStyle(name: name),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("设备调整", style: TextStyle(fontSize: 20)),
              content: SizedBox(child: DataPicker(name: name)),
            );
          },
        );
      },
    );
  }
}
