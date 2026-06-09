import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/report_repository.dart';
import '../models/user.dart';
import '../models/customer.dart';
import '../models/report.dart';

// ─── Service providers ────────────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((_) => MockApiService());

// Overridden in main.dart after async init
final storageServiceProvider = Provider<StorageService>(
  (_) => throw UnimplementedError('Override with actual instance in main.dart'),
);

// ─── Repository providers ─────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(apiServiceProvider),
    ref.read(storageServiceProvider),
  );
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.read(apiServiceProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.read(apiServiceProvider));
});

// ─── Theme provider ───────────────────────────────────────────────────────────

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);

// ─── Auth provider ────────────────────────────────────────────────────────────

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) => AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _loadStored();
  }

  void _loadStored() {
    final user = _repo.getStoredUser();
    if (user != null) state = AuthState(user: user);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.login(email, password);
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// ─── Customers provider ───────────────────────────────────────────────────────

class CustomerState {
  final List<Customer> customers;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;

  const CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery = '',
  });

  List<Customer> get filtered {
    if (searchQuery.isEmpty) return customers;
    final q = searchQuery.toLowerCase();
    return customers.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  CustomerState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
  }) =>
      CustomerState(
        customers: customers ?? this.customers,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  final CustomerRepository _repo;

  CustomerNotifier(this._repo) : super(const CustomerState()) {
    fetch();
  }

  Future<void> fetch({bool refresh = false}) async {
    if (refresh) {
      state = const CustomerState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }
    try {
      final list = await _repo.getCustomers(page: 1);
      state = CustomerState(
        customers: list,
        currentPage: 1,
        hasMore: list.length == CustomerRepository.pageSize,
      );
    } catch (e) {
      state = CustomerState(error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final next = state.currentPage + 1;
      final list = await _repo.getCustomers(page: next);
      state = state.copyWith(
        customers: [...state.customers, ...list],
        currentPage: next,
        hasMore: list.length == CustomerRepository.pageSize,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final customerProvider =
    StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  return CustomerNotifier(ref.read(customerRepositoryProvider));
});

// ─── Report / dashboard provider ─────────────────────────────────────────────

class ReportState {
  final List<Report> reports;
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;

  const ReportState({
    this.reports = const [],
    this.stats,
    this.isLoading = false,
    this.error,
  });

  ReportState copyWith({
    List<Report>? reports,
    DashboardStats? stats,
    bool? isLoading,
    String? error,
  }) =>
      ReportState(
        reports: reports ?? this.reports,
        stats: stats ?? this.stats,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportRepository _repo;

  ReportNotifier(this._repo) : super(const ReportState()) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _repo.getReports(),
        _repo.getDashboardStats(),
      ]);
      state = ReportState(
        reports: results[0] as List<Report>,
        stats: results[1] as DashboardStats,
      );
    } catch (e) {
      state = ReportState(error: e.toString());
    }
  }
}

final reportProvider =
    StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.read(reportRepositoryProvider));
});
