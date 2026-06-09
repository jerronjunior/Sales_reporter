import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/customer.dart';
import '../models/report.dart';

// ─── Exceptions ──────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  @override
  String toString() => message;
}

// ─── Response models ─────────────────────────────────────────────────────────

class LoginResponse {
  final bool success;
  final String token;
  final User user;

  const LoginResponse({
    required this.success,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json['success'] as bool,
        token: json['token'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class DashboardStats {
  final int totalCustomers;
  final int totalSales;
  final double totalRevenue;

  const DashboardStats({
    required this.totalCustomers,
    required this.totalSales,
    required this.totalRevenue,
  });
}

// ─── Abstract interface ───────────────────────────────────────────────────────

abstract class ApiService {
  Future<LoginResponse> login(String email, String password);
  Future<List<Customer>> getCustomers({int page = 1, int limit = 20});
  Future<List<Report>> getReports();
  Future<DashboardStats> getDashboardStats();
}

// ─── HTTP implementation (ready for real backend) ─────────────────────────────

class HttpApiService implements ApiService {
  final String baseUrl;
  final http.Client _client;
  String? _token;

  HttpApiService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Future.value(jsonDecode(response.body));
    }
    if (response.statusCode == 401) {
      throw const ApiException('Invalid email or password', 401);
    }
    throw ApiException(
      'Server error: ${response.statusCode}',
      response.statusCode,
    );
  }

  @override
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = await _handleResponse(response);
      return LoginResponse.fromJson(data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('No internet connection. Please check your network.');
    }
  }

  @override
  Future<List<Customer>> getCustomers({int page = 1, int limit = 20}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/customers?page=$page&limit=$limit'),
        headers: _headers,
      );
      final data = await _handleResponse(response) as List;
      return data
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('No internet connection. Please check your network.');
    }
  }

  @override
  Future<List<Report>> getReports() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/reports'),
        headers: _headers,
      );
      final data = await _handleResponse(response) as List;
      return data
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('No internet connection. Please check your network.');
    }
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: _headers,
      );
      final data = await _handleResponse(response) as Map<String, dynamic>;
      return DashboardStats(
        totalCustomers: data['totalCustomers'] as int,
        totalSales: data['totalSales'] as int,
        totalRevenue: (data['totalRevenue'] as num).toDouble(),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('No internet connection. Please check your network.');
    }
  }
}

// ─── Mock implementation ──────────────────────────────────────────────────────

class MockApiService implements ApiService {
  final _mockCustomers = [
    Customer(id: 1,  name: 'James Silva',          email: 'james@example.com',    phone: '+94 711234567'),
    Customer(id: 2,  name: 'Priya Nair',            email: 'priya@example.com',    phone: '+94 722345678'),
    Customer(id: 3,  name: 'Ravi Fernando',         email: 'ravi@example.com',     phone: '+94 733456789'),
    Customer(id: 4,  name: 'Nisha Perera',          email: 'nisha@example.com',    phone: '+94 744567890'),
    Customer(id: 5,  name: 'Amal Gunawardena',      email: 'amal@example.com',     phone: '+94 755678901'),
    Customer(id: 6,  name: 'Lakshmi Kumar',         email: 'lakshmi@example.com',  phone: '+94 766789012'),
    Customer(id: 7,  name: 'Nuwan Jayasinghe',      email: 'nuwan@example.com',    phone: '+94 777890123'),
    Customer(id: 8,  name: 'Sara Mendis',           email: 'sara@example.com',     phone: '+94 788901234'),
    Customer(id: 9,  name: 'Kamal De Silva',        email: 'kamal@example.com',    phone: '+94 799012345'),
    Customer(id: 10, name: 'Tharushi Wickrama',     email: 'tharushi@example.com', phone: '+94 700123456'),
    Customer(id: 11, name: 'Mohamed Faris',         email: 'faris@example.com',    phone: '+94 711234560'),
    Customer(id: 12, name: 'Dinesh Rajapaksa',      email: 'dinesh@example.com',   phone: '+94 722345670'),
    Customer(id: 13, name: 'Chamari Senanayake',    email: 'chamari@example.com',  phone: '+94 733456780'),
    Customer(id: 14, name: 'Harsha Bandara',        email: 'harsha@example.com',   phone: '+94 744567800'),
    Customer(id: 15, name: 'Rashmi Dissanayake',    email: 'rashmi@example.com',   phone: '+94 755678900'),
    Customer(id: 16, name: 'Sanjay Patel',          email: 'sanjay@example.com',   phone: '+94 766789000'),
    Customer(id: 17, name: 'Amara Wijeratne',       email: 'amara@example.com',    phone: '+94 777890000'),
    Customer(id: 18, name: 'Rohan Cooray',          email: 'rohan@example.com',    phone: '+94 788900000'),
    Customer(id: 19, name: 'Nilmini Herath',        email: 'nilmini@example.com',  phone: '+94 799000000'),
    Customer(id: 20, name: 'Dilan Jayawardena',     email: 'dilan@example.com',    phone: '+94 700000001'),
    Customer(id: 21, name: 'Kavya Nanayakkara',     email: 'kavya@example.com',    phone: '+94 711000002'),
    Customer(id: 22, name: 'Suresh Liyanage',       email: 'suresh@example.com',   phone: '+94 722000003'),
    Customer(id: 23, name: 'Manisha Fernando',      email: 'manisha@example.com',  phone: '+94 733000004'),
    Customer(id: 24, name: 'Ruwan Samaraweera',     email: 'ruwan@example.com',    phone: '+94 744000005'),
    Customer(id: 25, name: 'Lalith Pathirana',      email: 'lalith@example.com',   phone: '+94 755000006'),
  ];

  final _mockReports = const [
    Report(month: 'Jan', revenue: 5000,  orders: 42),
    Report(month: 'Feb', revenue: 6500,  orders: 55),
    Report(month: 'Mar', revenue: 7200,  orders: 61),
    Report(month: 'Apr', revenue: 6800,  orders: 58),
    Report(month: 'May', revenue: 8100,  orders: 70),
    Report(month: 'Jun', revenue: 9400,  orders: 82),
    Report(month: 'Jul', revenue: 8700,  orders: 75),
    Report(month: 'Aug', revenue: 10200, orders: 89),
    Report(month: 'Sep', revenue: 11000, orders: 95),
    Report(month: 'Oct', revenue: 9800,  orders: 84),
    Report(month: 'Nov', revenue: 12500, orders: 108),
    Report(month: 'Dec', revenue: 15000, orders: 130),
  ];

  @override
  Future<LoginResponse> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.trim() == 'test@test.com' && password == '123456') {
      return LoginResponse(
        success: true,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        user: const User(id: 1, name: 'John Doe', email: 'test@test.com'),
      );
    }
    throw const ApiException('Invalid email or password. Please try again.', 401);
  }

  @override
  Future<List<Customer>> getCustomers({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final start = (page - 1) * limit;
    if (start >= _mockCustomers.length) return [];
    final end = (start + limit).clamp(0, _mockCustomers.length);
    return _mockCustomers.sublist(start, end);
  }

  @override
  Future<List<Report>> getReports() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _mockReports;
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const DashboardStats(
      totalCustomers: 120,
      totalSales: 450,
      totalRevenue: 50000,
    );
  }
}
