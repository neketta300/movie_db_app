// класс ошибок

enum ApiCLientExceptionType { network, auth, other, sessionExpired, apiKey }

class ApiClientException implements Exception {
  final ApiCLientExceptionType type;

  ApiClientException(this.type);
}
