import 'package:flutter/material.dart';
import 'sidebar_items/config.dart';

class MenuDrawHeader extends StatelessWidget {
  const MenuDrawHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 233, 210, 227),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.vpn_lock,
            size: 35,
            color: Color.fromARGB(255, 69, 97, 113),
          ),

          Expanded(child: SizedBox()),

          Text(
            'Liutech ESP8266 Controller',
            style: TextStyle(
              color: Color.fromARGB(255, 97, 55, 55),
              fontSize: 18,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Preview Version: V1.6.2',
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          MenuDrawHeader(), // DrawerHeader 显示头部信息

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('配置'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigPage()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.info),
            title: Text('关于'),
            onTap: () {
              // Navigator.pop(context);
              // print('点击了关于');
            },
          ),
        ],
      ),
    );
  }
}
