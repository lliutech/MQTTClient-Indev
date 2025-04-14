import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'package:get/get.dart';
import '../utils/toast.dart';
import '../templates/config_template.dart';

// ignore: must_be_immutable
class DataPicker extends StatefulWidget {
  String name;
  DataPicker({super.key, required this.name});
  @override
  DataPickerState createState() => DataPickerState();
}

class DataPickerState extends State<DataPicker> {
  final DataController c = Get.find<DataController>();
  late TextEditingController _controller;
  late Map thisDeviceConfig;
  late String thisDeviceName;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    thisDeviceName = c.devices.value[widget.name]["connectionName"];
    thisDeviceConfig = c.devices.value[widget.name]["deviceConfig"];
    if (thisDeviceConfig["duration"] == null) {
      _controller = TextEditingController();
    } else {
      _controller = TextEditingController(
        text: thisDeviceConfig["duration"].toString(),
      );
    }
  }

  Future<void> selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        thisDeviceConfig["openHour"] = picked.hour;
        thisDeviceConfig["openMinute"] = picked.minute;
      });
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      if (thisDeviceConfig["openHour"] == null) {
        showToast("请先选择开始时间！");
        return;
      } else {
        if (picked.hour * 60 + picked.minute <
            thisDeviceConfig["openHour"] * 60 +
                thisDeviceConfig["openMinute"]) {
          showToast("结束时间必须晚于开始时间！");
          return;
        }
      }
      setState(() {
        thisDeviceConfig["closeHour"] = picked.hour;
        thisDeviceConfig["closeMinute"] = picked.minute;
      });
    }
  }

  void mergedConfig() {
    final oH = thisDeviceConfig["openHour"];
    final cH = thisDeviceConfig["closeHour"];

    final cM = thisDeviceConfig["closeMinute"];
    final oM = thisDeviceConfig["openMinute"];

    // 设置到最新时间
    void setTime(int duration) {
      if ((now.hour != oH || now.minute != oM) && now.minute - oM <= 1) {
        thisDeviceConfig["openMinute"] = now.minute;
      }
      thisDeviceConfig["duration"] = duration;
    }

    void configDevice() {
      c.updateDevice(
        widget.name,
        DeviceConfig(
          connectionName: thisDeviceName,
          functions: thisDeviceConfig["functions"],
          openHour: thisDeviceConfig["openHour"],
          openMinute: thisDeviceConfig["openMinute"],
          closeHour: thisDeviceConfig["closeHour"],
          closeMinute: thisDeviceConfig["closeMinute"],
          duration: thisDeviceConfig["duration"],
          targetStatue: thisDeviceConfig["targetStatue"] ?? false,
        ).tMap(),
      );
    }

    // 仅设置开始
    if ((oM != null && oH != null) && (cM == null && cH == null)) {
      showToast("开始时间: $oH:$oM，计时时长：${_controller.value.text}分");
      setTime(int.parse(_controller.value.text));
      configDevice();
    } else if ((oM != null && oH != null) && (cM != null && cH != null)) {
      final dif = (cH * 60 + cM) - (oH * 60 + oM);
      showToast("开始时间: $oH:$oM，结束时间: $cH:$cM，间隔：$dif分");
      setTime(dif);
      configDevice();
    }

    // if ((oM == null && oH == null) && (cM != null && cH != null)) {
    //   showToast("仅设置结束");
    // }

    // if (oM == null && oH == null && cM == null && cH == null) {
    //   showToast("都未设置");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              (thisDeviceConfig["openHour"] != null &&
                      thisDeviceConfig["openMinute"] != null)
                  ? '已选择: ${thisDeviceConfig["openHour"]}时${thisDeviceConfig["openMinute"]}分'
                  : '未选择开始时间: ',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(width: 10),
            Tooltip(
              message: "起始时间选择",
              child: IconButton(
                onPressed: () => selectStartTime(context),
                icon: Icon(Icons.slow_motion_video),
              ),
            ),
            Tooltip(
              message: "清除",
              child: IconButton(
                onPressed: () {
                  setState(() {
                    thisDeviceConfig["openHour"] = null;
                    thisDeviceConfig["openMinute"] = null;
                  });
                },
                icon: Icon(Icons.clear),
              ),
            ),
          ],
        ),

        Row(
          children: [
            Text(
              (thisDeviceConfig["closeHour"] != null &&
                      thisDeviceConfig["closeMinute"] != null)
                  ? '已选择: ${thisDeviceConfig["closeHour"]}时${thisDeviceConfig["closeMinute"]}分'
                  : '未选择结束时间: ',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(width: 10),
            Tooltip(
              message: "结束时间选择",
              child: IconButton(
                onPressed: () => selectEndTime(context),
                icon: Icon(Icons.slow_motion_video),
              ),
            ),

            Tooltip(
              message: "清除",
              child: IconButton(
                onPressed: () {
                  setState(() {
                    thisDeviceConfig["closeHour"] = null;
                    thisDeviceConfig["closeMinute"] = null;
                  });
                },
                icon: Icon(Icons.clear),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        TextField(
          controller: _controller,
          onChanged: (value) {
            thisDeviceConfig["duration"] = value;
          },
          autofocus: false,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // 仅允许输入数字
          ],
          decoration: InputDecoration(
            labelText: '请输入时间，以分钟为单位',
            border: OutlineInputBorder(),
            // errorText: _errorText.isNotEmpty ? _errorText : null, // 显示错误提示
          ),

          onSubmitted: (value) {
            setState(() {});
          },
        ),

        SwitchListTile(
          title: Text("状态"),
          value: thisDeviceConfig["targetStatue"],
          onChanged: (v) {
            setState(() {
              thisDeviceConfig["targetStatue"] = v;
            });
          },
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text("关闭"),
            ),
            TextButton(
              onPressed: () {
                mergedConfig();
              },
              child: Text("应用"),
            ),
          ],
        ),
      ],
    );
  }
}
