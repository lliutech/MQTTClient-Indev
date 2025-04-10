import 'package:shared_preferences/shared_preferences.dart';

Future<void> savePreferences(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<dynamic> readPreferences(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<dynamic> removePreferences(String key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}
