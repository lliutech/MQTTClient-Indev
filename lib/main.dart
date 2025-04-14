import 'dart:developer';
import 'dart:io';
import 'package:esp8266_controller/add_device/edit_device.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'templates/config_template.dart';

import 'templates/widgets.dart';
import 'sidebar.dart';

void main() async {
  String? dbPath;
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    Directory directory = (await getExternalStorageDirectory())!;
    dbPath = "${directory.path}/userData";
  } else {
    dbPath = "./userData";
  }

  await Hive.initFlutter();
  // 向DataController注入信息
  Get.put(
    DataController(
      connectionInfo: await Hive.openBox<Map>("ConnectionInfo", path: dbPath),
      deviceInfo: await Hive.openBox<Map>("DeviceInfo", path: dbPath),
    ),
  );

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
    connectConfig.value = connectionInfo.toMap();
    configNum.value = connectConfig.value.length;
    configNames.value = connectConfig.value.keys.toList();

    devices.value = deviceInfo.toMap();
    deviceNum.value = devices.value.length;
    deviceNames.value = devices.value.keys.toList();
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
    await connectionInfo.delete(name);
    await _update();
  }

  Future readDevice(name) async {
    return await deviceInfo.get(name);
  }

  // Future<void> clearDevice() async {
  //   await deviceInfo.clear();
  //   await _update();
  // }

  // Future<void> addDevice() async {
  //   String name = WordPair.random().toString();
  //   List<String> words = List.generate(8, (i) => WordPair.random().toString());

  //   final config =
  //       DeviceConfig(
  //         connectionName: words[1],
  //         functions: false,
  //         openHour: words[3],
  //         openMinute: words[4],
  //         closeHour: words[5],
  //         closeMinute: words[6],
  //         duration: null,
  //         targetStatue: false,
  //       ).tMap();

  //   updateDevice(name, config);
  // }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {
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
      //disconnectFromServer(); // 断开服务器连接
    } else if (state == AppLifecycleState.resumed) {
      // 应用回到前台
      log("App is in the foreground.");
      //reconnectToServer(); // 重新连接服务器
    }
  }

  List<Widget> initStartPage(DataController c) {
    // 当此处被运行deviceNum一定大于0
    return List.generate(c.deviceNum.value, (i) {
      String name = c.deviceNames.value[i];

      return c.devices.value[name]["deviceConfig"]["functions"] == true
          ? InitPageTapableGrid(name: name)
          : InitPageTaplessGrid(name: name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DataController c = Get.find<DataController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,

      drawer: SideMenu(),

      appBar: AppBar(
        title: Text("Tests APP"),
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
                    children: initStartPage(c),
                  ),
                )
                : Center(child: Text("未找到任何设备，请点击右上角添加一个。")),
      ),
    );
  }
}
