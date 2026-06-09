import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Token
  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);
  String? getToken() => _prefs.getString(_tokenKey);

  // User
  Future<void> saveUser({
    required int id,
    required String name,
    required String email,
  }) async {
    await _prefs.setInt(_userIdKey, id);
    await _prefs.setString(_userNameKey, name);
    await _prefs.setString(_userEmailKey, email);
  }

  int? getUserId() => _prefs.getInt(_userIdKey);
  String? getUserName() => _prefs.getString(_userNameKey);
  String? getUserEmail() => _prefs.getString(_userEmailKey);

  // Clear everything on logout
  Future<void> clearAll() => _prefs.clear();

  bool get isLoggedIn => getToken() != null;
}
