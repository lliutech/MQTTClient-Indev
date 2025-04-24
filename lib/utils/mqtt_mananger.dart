import 'dart:developer';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:get/get.dart';

class MqttManager {
  final RxBool isConnected = false.obs;
  late MqttServerClient client = MqttServerClient.withPort("", "", 8883);

  Future<void> connect(
    String server,
    int port,
    String clientId,
    String certPath,
    String? username,
    String? password,
    String? topic,
  ) async {
    client = MqttServerClient.withPort(server, clientId, port);
    // 设置安全连接（使用证书）
    client.secure = true;
    client.setProtocolV311();

    // 加载证书文件
    final securityContext = SecurityContext.defaultContext;
    try {
      securityContext.setTrustedCertificates(certPath); // 设置CA证书
    } catch (e) {
      print(e);
    }

    // 设置连接选项
    final connMessage =
        MqttConnectMessage()
            .authenticateAs(username, password) // 替换为你的用户名和密码
            .withWillTopic('willtopic')
            .withWillMessage('Will message')
            .startClean();

    client.connectionMessage = connMessage;

    // 监听连接状态的变化
    client.onDisconnected = () {
      isConnected.value = false;
    };

    client.onConnected = () {
      isConnected.value = true;
    };
    // 尝试连接服务器
    try {
      await client.connect();
      client.subscribe(topic.toString(), MqttQos.atLeastOnce);
      log("LinkSuccess");
    } catch (e) {
      log("LinkFailed Because: $e");
    }

    // 设置回调函数
    // client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
    //   for (var message in messages) {
    //     final topic = message.topic;
    //     final payload = message.payload as MqttPublishMessage;
    //     final data = String.fromCharCodes(payload.payload.message);
    //     log('Received message on topic: $topic, data: $data');
    //   }
    // });
  }

  void publishMessage(String topic, String message) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Published message: $message to topic: $topic');
    } else {
      print('Client not connected');
    }
  }

  int disconnect() {
    try {
      client.disconnect();
      print("DisconnectSuccess");
      return 1;
    } catch (e) {
      print("Disconnect: Because $e");
      return 0;
    }
  }
}
