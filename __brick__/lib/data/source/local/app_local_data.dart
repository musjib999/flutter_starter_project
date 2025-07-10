import 'dart:convert';
import 'local_data.dart';

import '../../../features/user/model/user.dart';

class AppLocalData extends LocalData {
  Future<void> saveUser({required User user}) async {
    String userJson = User.userToJson(user);
    await super.saveString(key: 'user', value: userJson);
  }

  Future<User?> getUser() async {
    String? userJson = await super.readString(key: 'user');
    if (userJson != null && userJson.isNotEmpty) {
      return User.userFromJson(userJson);
    } else {
      return null;
    }
  }

  Map<String, String> setHeader(Map<String, String> header) {
    super.saveString(key: 'header', value: jsonEncode(header));
    return header;
  }

  Future<Map<String, String>> getAuthorizedHeader() async {
    final data = await super.readString(key: 'header');

    final Map<String, dynamic> decodedHeader = jsonDecode(data!);

    final Map<String, String> header = decodedHeader.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );

    return header;
  }

  Future<void> newUserState() async {
    return await super.saveBoolToLocal(key: 'newUser', value: true);
  }

  Future<bool?> getNewUserState() async {
    return await super.readBoolFromLocal(key: 'newUser');
  }
}
