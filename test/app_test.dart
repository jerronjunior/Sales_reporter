import 'package:flutter_test/flutter_test.dart';
import 'package:sales_reporter/services/api_service.dart';
import 'package:sales_reporter/repositories/auth_repository.dart';
import 'package:sales_reporter/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Login service', () {
    late MockApiService api;
    setUp(() => api = MockApiService());

    test('valid credentials return user', () async {
      final res = await api.login('test@test.com', '123456');
      expect(res.success, true);
      expect(res.user.name, 'John Doe');
      expect(res.token.isNotEmpty, true);
    });

    test('wrong credentials throw ApiException', () {
      expect(() => api.login('wrong@email.com', 'wrong'),
          throwsA(isA<ApiException>()));
    });

    test('wrong password throws ApiException', () {
      expect(() => api.login('test@test.com', 'wrong'),
          throwsA(isA<ApiException>()));
    });
  });

  group('Customer repository', () {
    late MockApiService api;
    setUp(() => api = MockApiService());

    test('returns customers list', () async {
      final list = await api.getCustomers();
      expect(list, isNotEmpty);
    });

    test('pagination returns correct pages', () async {
      final p1 = await api.getCustomers(page: 1, limit: 10);
      final p2 = await api.getCustomers(page: 2, limit: 10);
      expect(p1.length, 10);
      expect(p1.first.id, isNot(equals(p2.first.id)));
    });

    test('beyond last page returns empty', () async {
      final list = await api.getCustomers(page: 999);
      expect(list, isEmpty);
    });
  });

  group('Auth repository', () {
    late AuthRepository repo;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      repo = AuthRepository(MockApiService(), storage);
    });

    test('not logged in before login', () => expect(repo.isLoggedIn, false));

    test('login saves user', () async {
      await repo.login('test@test.com', '123456');
      expect(repo.isLoggedIn, true);
      expect(repo.getStoredUser()?.name, 'John Doe');
    });

    test('logout clears data', () async {
      await repo.login('test@test.com', '123456');
      await repo.logout();
      expect(repo.isLoggedIn, false);
    });
  });
}
