import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  Future<void> saveString({required String key, required String value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> readString({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveDate({required String key, required DateTime date}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dateString = date.toIso8601String();
    await prefs.setString(key, dateString);
  }

  Future<DateTime?> readDate({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dateString = prefs.getString(key);
    if (dateString != null) {
      DateTime savedDate = DateTime.tryParse(dateString) ?? DateTime.now();
      return savedDate;
    }

    return null;
  }

  Future<void> saveBoolToLocal(
      {required String key, required bool value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> readBoolFromLocal({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool(key);
    return value;
  }

  Future<bool> clearStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
