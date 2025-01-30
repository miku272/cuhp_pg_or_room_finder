import 'package:shared_preferences/shared_preferences.dart';

class SFHandler {
  static const String _tokenKey = 'x-auth-token';
  static const String _expiresIn = 'expiresIn';
  static const String _id = '_id';
  final SharedPreferences prefs;

  SFHandler({required this.prefs});

  Future<bool> setToken(String token) async {
    return await prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return prefs.getString(_tokenKey);
  }

  Future<bool> deleteToken() async {
    return await prefs.remove(_tokenKey);
  }

  Future<bool> setExpiresIn(String expiresIn) async {
    return await prefs.setString(_expiresIn, expiresIn);
  }

  String? getExpiresIn() {
    return prefs.getString(_expiresIn);
  }

  Future<bool> deleteExpiresIn() async {
    return await prefs.remove(_expiresIn);
  }

  Future<bool> setId(String id) async {
    return await prefs.setString(_id, id);
  }

  String? getId() {
    return prefs.getString(_id);
  }

  Future<bool> deleteId() async {
    return await prefs.remove(_id);
  }
}
