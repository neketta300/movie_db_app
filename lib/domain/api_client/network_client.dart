//отвечает за выход в сеть надстройка над стандартым http

import 'dart:convert';
import 'dart:io';
import 'package:moviedb_app_llf/config/configuration.dart';
import 'package:moviedb_app_llf/domain/api_client/api_client_exception.dart';

class NetworkClient {
  final _client = HttpClient();
  Uri makeUri(String path, [Map<String, dynamic>? queryParameters]) {
    final uri = Uri.parse('${Configuration.host}$path');
    if (queryParameters != null) {
      return uri.replace(queryParameters: queryParameters);
    } else {
      return uri;
    }
  }

  Future<T> get<T>(
    String path,
    T Function(dynamic json) parser, [
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  ]) async {
    final url = makeUri(path, queryParameters);
    try {
      final request = await _client.getUrl(url);
      // Добавляем заголовки из параметра headers
      headers?.forEach((key, value) {
        request.headers.add(key, value.toString());
      });
      final response = await request.close();
      final dynamic json = (await response.jsonDecode());

      _validateResponse(response, json);

      final result = parser(json);
      return result;
    } on SocketException {
      throw ApiClientException(ApiCLientExceptionType.network);
    } on ApiClientException {
      rethrow;
    } catch (_) {
      throw ApiCLientExceptionType.other;
    }
  }

  Future<T> post<T>(
    String path,
    T Function(dynamic json) parser,
    Map<String, dynamic> headers,
    Map<String, dynamic> bodyParameters, [
    Map<String, dynamic>? queryParameters,
  ]) async {
    final url = makeUri(path, queryParameters);
    try {
      final request = await _client.postUrl(url);

      headers.forEach((key, value) {
        request.headers.add(key, value.toString());
      });
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(bodyParameters));
      final response = await request.close();
      final dynamic json = (await response.jsonDecode());

      _validateResponse(response, json);

      final result = parser(json);
      return result;
    } on SocketException {
      throw ApiClientException(ApiCLientExceptionType.network);
    } on ApiClientException {
      rethrow;
    } catch (_) {
      throw ApiCLientExceptionType.other;
    }
  }

  void _validateResponse(HttpClientResponse response, dynamic json) {
    if (response.statusCode == 401) {
      final dynamic status = json['status_code'];
      final code = status is int ? status : 0;
      if (code == 30) {
        throw ApiClientException(ApiCLientExceptionType.auth);
      } else if (code == 3) {
        throw ApiClientException(ApiCLientExceptionType.sessionExpired);
      } else {
        throw ApiClientException(ApiCLientExceptionType.other);
      }
    }
  }
}

extension HttpClientResponseJsonDecode on HttpClientResponse {
  Future<dynamic> jsonDecode() async {
    return transform(utf8.decoder)
        .toList()
        .then((value) => value.join())
        .then<dynamic>((v) => json.decode(v));
  }
}
