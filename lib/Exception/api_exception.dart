class ApiException implements Exception {
  final String message;
  final int code;
  final dynamic errorBody;

  ApiException({required this.message, required this.code, this.errorBody});

  @override
  String toString() => 'ApiException ($code): $message';
}
