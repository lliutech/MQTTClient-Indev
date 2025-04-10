import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../Utils/mqtt_mananger.dart';

// ignore: must_be_immutable
class ConnectRow extends StatefulWidget {
  final MqttManager mqttManager;
  late Map<String, dynamic> config;

  ConnectRow({super.key, required this.mqttManager, required this.config});

  @override
  ConnectRowState createState() => ConnectRowState();
}

class ConnectRowState extends State<ConnectRow> {
  void _showDialog(String error) async {
    bool? _ = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("警告: "),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: Text("确定"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<void> connectMqtt() async {
    if (widget.mqttManager.client.connectionStatus!.state ==
        MqttConnectionState.disconnected) {
      String err = await widget.mqttManager.connect(
        widget.config["addr"].toString(),
        widget.config["port"] ?? 0,
        widget.config["主题"] ?? "", // ClientID
        widget.config["证书路径"].toString(),
        widget.config["用户名"] ?? "",
        widget.config["密码"] ?? "",
        widget.config["主题"] ?? "",
      );

      if (widget.mqttManager.client.connectionStatus!.state ==
          MqttConnectionState.disconnected) {
        _showDialog(err);
      }
    } else {
      widget.mqttManager.disconnect();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              (widget.mqttManager.client.connectionStatus!.state ==
                      MqttConnectionState.connected)
                  ? Icons.public
                  : Icons.public_off,
              color:
                  (widget.mqttManager.client.connectionStatus!.state ==
                          MqttConnectionState.connected)
                      ? Color.fromARGB(255, 8, 165, 95)
                      : Color.fromARGB(255, 255, 0, 0),
            ),
            Text(
              (widget.mqttManager.client.connectionStatus!.state ==
                      MqttConnectionState.connected)
                  ? "已连接"
                  : "未连接",
            ),
            ElevatedButton(
              onPressed: connectMqtt,
              child: Text(
                (widget.mqttManager.client.connectionStatus!.state ==
                        MqttConnectionState.connected)
                    ? "断开"
                    : "连接",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
