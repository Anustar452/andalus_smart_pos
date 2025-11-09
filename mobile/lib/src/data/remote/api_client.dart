import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:retrofit/retrofit.dart';
import 'package:andalus_smart_pos/src/data/models/product.dart';
import 'package:andalus_smart_pos/src/data/models/sale.dart';
import 'package:andalus_smart_pos/src/data/models/sale_item.dart';

part 'api_client.g.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});

@RestApi(baseUrl: 'https://your-backend.com/api')
abstract class ApiClient {
  factory ApiClient(Ref ref) {
    final dio = Dio();

    // Add interceptors
    dio.interceptors.add(
      ApiInterceptors(
        secureStorage: ref.read(secureStorageProvider),
      ),
    );

    return _ApiClient(dio);
  }

  // Auth endpoints
  @POST('/auth/login')
  Future<LoginResponse> login(@Body() LoginRequest request);

  @POST('/auth/refresh')
  Future<RefreshResponse> refreshToken(@Body() RefreshRequest request);

  // Sync endpoints
  @POST('/sync/upload')
  Future<SyncResponse> uploadSyncData(@Body() Map<String, dynamic> data);

  @POST('/sync/download')
  Future<SyncResponse> downloadUpdates(@Body() DownloadRequest request);

  // Payment endpoints
  @POST('/payments/initiate')
  Future<PaymentInitiationResponse> initiatePayment(
      @Body() PaymentRequest request);

  @GET('/payments/{paymentId}/status')
  Future<PaymentStatusResponse> getPaymentStatus(
      @Path('paymentId') String paymentId);
}

class ApiInterceptors extends Interceptor {
  final FlutterSecureStorage secureStorage;

  ApiInterceptors({required this.secureStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token to headers
    final token = await secureStorage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle token refresh on 401 errors
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic
    }

    handler.next(err);
  }
}

// Request/Response DTOs
class LoginRequest {
  final String email;
  final String password;
  final String? deviceId;

  LoginRequest({
    required this.email,
    required this.password,
    this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'device_id': deviceId,
      };
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token'],
        refreshToken: json['refresh_token'],
        user: User.fromJson(json['user']),
      );
}

class RefreshRequest {
  final String refreshToken;

  RefreshRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {
        'refresh_token': refreshToken,
      };
}

class RefreshResponse {
  final String accessToken;

  RefreshResponse({required this.accessToken});

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      RefreshResponse(
        accessToken: json['access_token'],
      );
}

class DownloadRequest {
  final int shopId;
  final int since;

  DownloadRequest({required this.shopId, required this.since});

  Map<String, dynamic> toJson() => {
        'shop_id': shopId,
        'since': since,
      };
}

class SyncResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  SyncResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) => SyncResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'],
      );
}

class PaymentRequest {
  final String saleId;
  final double amount;
  final String currency;

  PaymentRequest({
    required this.saleId,
    required this.amount,
    this.currency = 'ETB',
  });

  Map<String, dynamic> toJson() => {
        'sale_id': saleId,
        'amount': amount,
        'currency': currency,
      };
}

class PaymentInitiationResponse {
  final String paymentId;
  final String? telebirrQr;
  final String? deepLink;
  final String status;

  PaymentInitiationResponse({
    required this.paymentId,
    this.telebirrQr,
    this.deepLink,
    required this.status,
  });

  factory PaymentInitiationResponse.fromJson(Map<String, dynamic> json) =>
      PaymentInitiationResponse(
        paymentId: json['payment_id'],
        telebirrQr: json['telebirr_qr'],
        deepLink: json['deep_link'],
        status: json['status'],
      );
}

class PaymentStatusResponse {
  final String paymentId;
  final String status;
  final String? providerReference;

  PaymentStatusResponse({
    required this.paymentId,
    required this.status,
    this.providerReference,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) =>
      PaymentStatusResponse(
        paymentId: json['payment_id'],
        status: json['status'],
        providerReference: json['provider_reference'],
      );
}

// User model for auth
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int shopId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.shopId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        shopId: json['shop_id'],
      );
}

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});
