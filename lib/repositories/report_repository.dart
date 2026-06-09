import '../services/api_service.dart';
import '../models/report.dart';

class ReportRepository {
  final ApiService _api;
  ReportRepository(this._api);

  Future<List<Report>> getReports() => _api.getReports();
  Future<DashboardStats> getDashboardStats() => _api.getDashboardStats();
}
