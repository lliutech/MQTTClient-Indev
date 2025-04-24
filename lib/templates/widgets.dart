// ignore_for_file: must_be_immutable
import 'dart:developer';

import 'package:esp8266_controller/templates/config_template.dart';
import 'package:esp8266_controller/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main.dart';
import '../utils/data_picker.dart';

class CenterStyle extends StatelessWidget {
  String name;
  CenterStyle({super.key, required this.name});
  final DataController c = Get.find<DataController>();
  final ConnectionController controlController =
      Get.find<ConnectionController>();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(name, style: TextStyle(fontSize: 18)),
              Obx(
                () =>
                    controlController
                                .connections
                                .value[name]!
                                .isConnected
                                .value ==
                            false
                        ? Icon(Icons.vpn_lock, color: Colors.red, size: 20)
                        : Icon(Icons.vpn_lock, color: Colors.green, size: 20),
              ),
            ],
          ),
          SizedBox(height: 5),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: c.devices.value[name]["deviceConfig"]["manualStatue"],
              onChanged: (v) {
                c.devices.value[name]["deviceConfig"]["manualStatue"] = v;
                c.updateDevice(name, c.devices.value[name]);
                String configName = c.devices.value[name]["connectionName"];
                String message =
                    DeviceControl(
                      mode: "2",
                      openHour: null,
                      openMinute: null,
                      closeHour: null,
                      closeMinute: null,
                      targetStatue: null,
                      duration: null,
                      manualStatue: v,
                    ).tString();
                controlController.connections.value[name]!.publishMessage(
                  c.connectConfig.value[configName]["topic"],
                  message,
                );
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
                        final config = c.devices.value[name]["deviceConfig"];
                        String configName =
                            c.devices.value[name]["connectionName"];
                        String message =
                            DeviceControl(
                              mode: "1",
                              openHour: config["openHour"],
                              openMinute: config["openMinute"],
                              closeHour: config["closeHour"],
                              closeMinute: config["closeMinute"],
                              targetStatue: config["targetStatue"],
                              duration: config["duration"],
                              manualStatue: false,
                            ).tString();
                        log(message);

                        controlController.connections.value[name]!
                            .publishMessage(
                              c.connectConfig.value[configName]["topic"],
                              message,
                            );
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
