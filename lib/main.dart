import 'dart:developer';
import 'dart:io';
import 'package:esp8266_controller/add_device/edit_device.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:path_provider/path_provider.dart';
import 'utils/mqtt_mananger.dart';
import 'templates/widgets.dart';
import 'sidebar.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  String dbPath =
      Platform.isAndroid
          ? "${(await getExternalStorageDirectory())!.path}/userData"
          : "./userData";

  await Hive.initFlutter();
  Get.put(
    DataController(
      connectionInfo: await Hive.openBox<Map>("ConnectionInfo", path: dbPath),
      deviceInfo: await Hive.openBox<Map>("DeviceInfo", path: dbPath),
    ),
  );

  Get.put(ConnectionController());
}

void main() async {
  await initializeApp();
  runApp(GetMaterialApp(home: Home()));
}

class DataController extends GetxController {
  final Box connectionInfo, deviceInfo;

  var connectConfig = Rx<Map>({});
  var configNum = Rx<int>(0);
  var configNames = Rx<List>([]);

  var devices = Rx<Map>({});
  var deviceNum = Rx<int>(0);
  var deviceNames = Rx<List>([]);

  DataController({required this.connectionInfo, required this.deviceInfo});

  Future<void> _update() async {
    _updateBox(connectionInfo, connectConfig, configNum, configNames);
    log("ConnectionInfo； ${configNum.value}");
    _updateBox(deviceInfo, devices, deviceNum, deviceNames);
  }

  void _updateBox(Box box, Rx<Map> target, Rx<int> count, Rx<List> names) {
    target.value = box.toMap();
    count.value = target.value.length;
    names.value = target.value.keys.toList();
  }

  @override
  void onInit() async {
    super.onInit();
    await _update();
  }

  Future<void> updateDevice(name, config) async {
    // config should be like
    // "deviceName": {"connectionName": "", "deviceConfig": {"functions": false, "openHour": null, "openMinute": null, "closeHour": null, "closeMinute": null, "targetStatue": false}}
    await deviceInfo.put(name, config);
    await _update();
  }

  Future<void> updateConfig(name, config) async {
    // config should be like
    // {configName: {"server": null, "port": null, "topic": null, "keyPath": null, "username": null, "password": null}}
    await connectionInfo.put(name, config);
    await _update();
  }

  Future<void> dropDevice(name) async {
    await deviceInfo.delete(name);
    await _update();
  }

  Future<void> dropConfig(name) async {
    print("before drop: $configNum");
    await connectionInfo.delete(name);
    await _update();
    print("after drop: $configNum");
  }

  Future readDevice(name) async {
    return await deviceInfo.get(name);
  }
}

class ConnectionController extends GetxController {
  var connections = Rx<Map<String, MqttManager>>({});

  void addDevice(name, Map config) {
    connections.value[name] = MqttManager();
    connections.value[name]!.connect(
      config["server"],
      config["port"],
      name,
      config["keypath"],
      config["username"],
      config["password"],
      config["topic"],
    );
  }

  void reconnect(name, Map config) {
    connections.value[name] = MqttManager();
    connections.value[name]!.connect(
      config["server"],
      config["port"],
      name,
      config["keypath"],
      config["username"],
      config["password"],
      config["topic"],
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {
  final DataController c = Get.find<DataController>();
  final ConnectionController controlController =
      Get.find<ConnectionController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 注册生命周期监听器
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除生命周期监听器
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // 应用进入后台
      log("App is in the background.");
      // disconnectFromServer(); // 断开服务器连接
    } else if (state == AppLifecycleState.resumed) {
      // 应用回到前台
      log("App is in the foreground.");
      reconnectforEach();
    }
  }

  List<Widget> initStartPage() {
    // 当此处被运行deviceNum一定大于0
    return List.generate(c.deviceNum.value, (i) {
      String name = c.deviceNames.value[i];
      String configName = c.devices.value[name]["connectionName"];
      Map currentConfig = c.connectConfig.value[configName];

      if (controlController.connections.value[name] == null) {
        controlController.addDevice(name, currentConfig);
      } else if (controlController
              .connections
              .value[name]!
              .client
              .connectionStatus!
              .state !=
          MqttConnectionState.connected) {
        controlController.reconnect(name, currentConfig);
      }

      return c.devices.value[name]["deviceConfig"]["functions"] == true
          ? InitPageTapableGrid(name: name)
          : InitPageTaplessGrid(name: name);
    });
  }

  void reconnectforEach() {
    for (var i in c.deviceNames.value) {
      String configName = c.devices.value[i]["connectionName"];
      Map currentConfig = c.connectConfig.value[configName];

      if (controlController.connections.value[i] == null) {
        controlController.addDevice(configName, currentConfig);
      } else if (controlController.connections.value[i]!.isConnected.value ==
          false) {
        controlController.reconnect(configName, currentConfig);
      } else {
        print(
          "ConnectionName: $configName skipped, Because it has already connected",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      drawer: SideMenu(),

      appBar: AppBar(
        title: Text("MQTT Client"),
        actions: [
          SizedBox(width: 25),
          IconButton(
            onPressed: () => Get.to(() => EditDevice()),

            icon: Icon(Icons.add),
          ),
          SizedBox(width: 25),
        ],
      ),

      body: Obx(
        () =>
            c.deviceNum.value > 0
                ? Container(
                  padding: EdgeInsets.all(5),
                  child: GridView.extent(
                    maxCrossAxisExtent: 200,
                    padding: const EdgeInsets.all(2.5),
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: initStartPage(),
                  ),
                )
                : Center(child: Text("未找到任何设备，请点击右上角添加一个。")),
      ),
    );
  }
}
