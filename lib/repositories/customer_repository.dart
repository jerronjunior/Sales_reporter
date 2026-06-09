import '../services/api_service.dart';
import '../models/customer.dart';

class CustomerRepository {
  final ApiService _api;
  CustomerRepository(this._api);

  static const int pageSize = 20;

  Future<List<Customer>> getCustomers({int page = 1}) =>
      _api.getCustomers(page: page, limit: pageSize);
}
