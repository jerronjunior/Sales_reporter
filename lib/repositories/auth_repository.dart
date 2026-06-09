import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiService _api;
  final StorageService _storage;

  AuthRepository(this._api, this._storage);

  bool get isLoggedIn => _storage.isLoggedIn;

  User? getStoredUser() {
    final id = _storage.getUserId();
    final name = _storage.getUserName();
    final email = _storage.getUserEmail();
    if (id == null || name == null) return null;
    return User(id: id, name: name, email: email ?? '');
  }

  Future<User> login(String email, String password) async {
    final response = await _api.login(email.trim(), password);
    await _storage.saveToken(response.token);
    await _storage.saveUser(
      id: response.user.id,
      name: response.user.name,
      email: response.user.email,
    );
    return response.user;
  }

  Future<void> logout() => _storage.clearAll();
}
