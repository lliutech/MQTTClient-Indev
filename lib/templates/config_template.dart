class ConnectConfig {
  String? server, topic, keyPath, userName, passWord;
  int port = 8883;

  ConnectConfig({
    required this.server,
    required this.port,
    required this.topic,
    required this.keyPath,
    required this.userName,
    required this.passWord,
  });

  Map tMap() {
    return {
      "server": server,
      "port": port,
      "topic": topic,
      "keypath": keyPath,
      "username": userName,
      "password": passWord,
    };
  }
}

// 用于处理主页面设备显示的配置
class DeviceConfig {
  String? connectionName;
  int? duration, openHour, openMinute, closeHour, closeMinute;
  bool functions, targetStatue, manualStatue;

  DeviceConfig({
    required this.connectionName,
    required this.functions,
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    required this.targetStatue,
    required this.duration,
    required this.manualStatue,
  });

  Map tMap() {
    return {
      "connectionName": connectionName,
      "deviceConfig": {
        "functions": functions,
        "openHour": openHour,
        "openMinute": openMinute,
        "closeHour": closeHour,
        "closeMinute": closeMinute,
        "duration": duration,
        "targetStatue": targetStatue,
        "manualStatue": manualStatue,
      },
    };
  }
}

// 用于处理设备发送指令的基本配置
class DeviceControl {
  String? mode;
  dynamic openHour, openMinute, closeHour, closeMinute;
  bool? targetStatue, manualStatue;
  int? duration;

  DeviceControl({
    required this.mode,
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    required this.targetStatue,
    required this.duration,
    required this.manualStatue,
  });

  String tString() {
    return {
      "mode": mode,
      "openHour": openHour,
      "openMinute": openMinute,
      "closeHour": closeHour,
      "closeMinute": closeMinute,
      "targetStatue": targetStatue,
      "manualStatue": manualStatue,
      "duration": duration,
    }.toString();
  }
}
