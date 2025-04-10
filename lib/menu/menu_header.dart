import 'package:flutter/material.dart';

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
            'Preview Version: V1.0.0',
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
