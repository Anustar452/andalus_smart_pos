// mobile/lib/src/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  // For production: static const String baseUrl = 'https://your-domain.com/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': deviceName,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Logout failed');
    }
  }

  // Products
  Future<List<Product>> getProducts({String? search}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/products').replace(queryParameters: params),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Product>.from(data['data'].map((x) => Product.fromJson(x)));
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: await _getHeaders(),
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create product');
    }
  }

  // Transactions
  Future<Transaction> createTransaction({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required double paidAmount,
    String? customerPhone,
    String? customerEmail,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'items': items,
        'payment_method': paymentMethod,
        'paid_amount': paidAmount,
        'customer_phone': customerPhone,
        'customer_email': customerEmail,
      }),
    );

    if (response.statusCode == 201) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create transaction: ${response.body}');
    }
  }

  Future<List<Transaction>> getTransactions({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final params = <String, String>{};
    if (dateFrom != null) {
      params['date_from'] = dateFrom.toIso8601String().split('T')[0];
    }
    if (dateTo != null) {
      params['date_to'] = dateTo.toIso8601String().split('T')[0];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/transactions').replace(queryParameters: params),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Transaction>.from(
        data['data'].map((x) => Transaction.fromJson(x)),
      );
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  // Reports
  Future<Map<String, dynamic>> getSalesSummary({String? period}) async {
    final params = <String, String>{};
    if (period != null) {
      params['period'] = period;
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/reports/sales-summary',
      ).replace(queryParameters: params),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load sales summary');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
