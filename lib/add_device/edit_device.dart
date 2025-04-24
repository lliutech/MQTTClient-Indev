import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/toast.dart';
import '../templates/config_template.dart';

// ignore: must_be_immutable
class EditDevice extends StatefulWidget {
  const EditDevice({super.key});

  @override
  EditDeviceState createState() => EditDeviceState();
}

class EditDeviceState extends State<EditDevice> {
  final _formKey = GlobalKey<FormState>();
  final DataController c = Get.find<DataController>();
  String? selectedValue;
  String deviceName = "";
  bool functions = false;
  bool targetStatue = false;
  int? openHour, openMinute, closeHour, closeMinute;
  int? duration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("编辑设备"),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              }

              final config =
                  DeviceConfig(
                    connectionName: selectedValue,
                    functions: functions,
                    openHour: openHour,
                    openMinute: openMinute,
                    closeHour: closeHour,
                    closeMinute: closeMinute,
                    duration: duration,
                    targetStatue: targetStatue,
                    manualStatue: false,
                  ).tMap();
              if (deviceName == "") {
                showToast("请输入配置名称！");
              } else if (selectedValue == null) {
                showToast("请选择连接配置！");
              } else {
                c.updateDevice(deviceName, config);
                showToast("保存成功");
              }
            },
            icon: Icon(Icons.save),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
            child: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(labelText: '设备名称'),
                validator: (value) => value!.isEmpty ? '必填项' : null,
                onSaved: (value) => deviceName = value!,
              ),
            ),
          ),
          //Divider(),
          Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                selectedValue == "" ? Text("未选择配置") : Text("配置已选择:"),
                DropdownButton<String>(
                  value: selectedValue,
                  hint: Text(
                    c.configNames.value.isEmpty == true
                        ? '无配置，请先添加一个配置'
                        : '请选择一个配置',
                    style: TextStyle(fontSize: 15),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                  items:
                      c.configNames.value.map<DropdownMenuItem<String>>((
                        value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 15)),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
          //Divider(),
          Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
            child: SwitchListTile(
              title: Text('启用定时?'),
              value: functions,
              onChanged: (v) {
                setState(() {
                  functions = v;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
