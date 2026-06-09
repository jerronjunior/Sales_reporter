import 'package:flutter_test/flutter_test.dart';
import 'package:sales_reporter/services/api_service.dart';
import 'package:sales_reporter/repositories/auth_repository.dart';
import 'package:sales_reporter/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockApiService - login', () {
    late MockApiService api;

    setUp(() => api = MockApiService());

    test('returns user on valid credentials', () async {
      final response = await api.login('test@test.com', '123456');
      expect(response.success, true);
      expect(response.user.name, 'John Doe');
      expect(response.token.isNotEmpty, true);
    });

    test('throws ApiException on invalid credentials', () async {
      expect(
        () => api.login('wrong@email.com', 'wrongpass'),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException on wrong password', () async {
      expect(
        () => api.login('test@test.com', 'wrongpass'),
        throwsA(isA<ApiException>()),
      );
    });

    test('returns non-empty token', () async {
      final response = await api.login('test@test.com', '123456');
      expect(response.token, isNotEmpty);
    });
  });

  group('AuthRepository', () {
    late AuthRepository repo;
    late MockApiService api;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      api = MockApiService();
      repo = AuthRepository(api, storage);
    });

    test('isLoggedIn is false before login', () {
      expect(repo.isLoggedIn, false);
    });

    test('login saves user and marks isLoggedIn', () async {
      await repo.login('test@test.com', '123456');
      expect(repo.isLoggedIn, true);
      expect(repo.getStoredUser()?.name, 'John Doe');
    });

    test('logout clears stored data', () async {
      await repo.login('test@test.com', '123456');
      await repo.logout();
      expect(repo.isLoggedIn, false);
      expect(repo.getStoredUser(), isNull);
    });

    test('throws on invalid login', () async {
      expect(
        () => repo.login('bad@email.com', 'badpass'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('MockApiService - customers', () {
    late MockApiService api;

    setUp(() => api = MockApiService());

    test('returns customers list', () async {
      final customers = await api.getCustomers();
      expect(customers, isNotEmpty);
    });

    test('pagination returns correct page', () async {
      final page1 = await api.getCustomers(page: 1, limit: 10);
      final page2 = await api.getCustomers(page: 2, limit: 10);
      expect(page1.length, 10);
      expect(page1.first.id, isNot(equals(page2.first.id)));
    });

    test('returns empty list beyond last page', () async {
      final beyond = await api.getCustomers(page: 999);
      expect(beyond, isEmpty);
    });
  });

  group('MockApiService - reports', () {
    late MockApiService api;

    setUp(() => api = MockApiService());

    test('returns 12 monthly reports', () async {
      final reports = await api.getReports();
      expect(reports.length, 12);
    });

    test('reports have positive revenue', () async {
      final reports = await api.getReports();
      for (final r in reports) {
        expect(r.revenue, greaterThan(0));
      }
    });
  });
}
