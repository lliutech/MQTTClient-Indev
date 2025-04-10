import 'package:flutter/material.dart';
import 'menu_header.dart';
import 'setting.dart';

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
            title: Text('设置'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
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
