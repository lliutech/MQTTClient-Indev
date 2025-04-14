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

class DeviceConfig {
  String? connectionName;
  int? duration, openHour, openMinute, closeHour, closeMinute;
  bool functions, targetStatue;

  DeviceConfig({
    required this.connectionName,
    required this.functions,
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    required this.targetStatue,
    required this.duration,
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
      },
    };
  }
}

class DeviceControl {
  String? mode,
      openHour,
      openMinute,
      closeHour,
      closeMinute,
      targetStatue,
      duration;

  String tString() {
    return {
      "mode": null,
      "openHour": openHour,
      "openMinute": openMinute,
      "closeHour": closeHour,
      "closeMinute": closeMinute,
      "targetStatue": targetStatue,
      "duration": duration,
    }.toString();
  }
}
