class ApiConstants {
  ApiConstants._();

  static const String baseUrl = '[http://10.0.2.2:8000/api/v1](http://10.0.2.2:8000/api/v1)';
  static const String analyzeEndpoint = '/screenings/analyze';
  static const String syncEndpoint = '/screenings/sync';
  static const Duration requestTimeout = Duration(seconds: 12);
}