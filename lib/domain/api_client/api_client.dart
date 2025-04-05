import 'dart:convert';
import 'dart:io';

import 'package:moviedb_app_llf/domain/entity/movie_details.dart';
import 'package:moviedb_app_llf/domain/entity/popular_movie_response.dart';

enum ApiCLientExceptionType { network, auth, other }

class ApiClientException implements Exception {
  final ApiCLientExceptionType type;

  ApiClientException(this.type);
}

class ApiClient {
  final _client = HttpClient();
  static const _host = 'https://api.themoviedb.org/3';
  static const _imageUrl = 'https://image.tmdb.org/t/p/w500';
  static const _apiKey = '0f51db296e08668c933ff3cb725b80b6';
  static const _apiKeyHeader =
      'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwZjUxZGIyOTZlMDg2NjhjOTMzZmYzY2I3MjViODBiNiIsIm5iZiI6MTcyODMwNTUxNS41MzQwMDAyLCJzdWIiOiI2NzAzZDk2YjdjZmVhNmYyMDI3M2ViYjEiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.vEKioOpWwrKkazShbyv8Zqu51cr8AFEvMZQV6s0vBLo';

  static String imageUrl(String path) => _imageUrl + path;

  Future<String> auth({
    required String username,
    required String password,
  }) async {
    final token = await _makeToken();
    final validToken = await _validateUser(
      username: username,
      password: password,
      requestToken: token,
    );
    final sessionId = await _makeSession(requestToken: validToken);
    return sessionId;
  }

  Uri _makeUri(String path, [Map<String, dynamic>? parameters]) {
    final uri = Uri.parse('$_host$path');
    if (parameters != null) {
      return uri.replace(queryParameters: parameters);
    } else {
      return uri;
    }
  }

  Future<T> _get<T>(
    String path,
    T Function(dynamic json) parser,
    Map<String, dynamic> headers, [
    Map<String, dynamic>? parameters,
  ]) async {
    final url = _makeUri(path, parameters);
    try {
      final request = await _client.getUrl(url);
      // Добавляем заголовки из параметра headers
      headers.forEach((key, value) {
        request.headers.add(key, value.toString());
      });
      final response = await request.close();
      final dynamic json = (await response.jsonDecode());

      _validateREsponse(response, json);

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

  Future<T> _post<T>(
    String path,
    T Function(dynamic json) parser,
    Map<String, dynamic> headers,
    Map<String, dynamic> bodyParameters, [
    Map<String, dynamic>? urlParameters,
  ]) async {
    final url = _makeUri(path, urlParameters);
    try {
      final request = await _client.postUrl(url);

      headers.forEach((key, value) {
        request.headers.add(key, value.toString());
      });
      request.headers.contentType = ContentType.json;

      request.write(jsonEncode(bodyParameters));
      final response = await request.close();
      final dynamic json = (await response.jsonDecode());

      _validateREsponse(response, json);

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

  Future<String> _makeToken() async {
    final parser = (dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token = jsonMap['request_token'] as String;
      return token;
    };

    final result = _get('/authentication/token/new', parser, <String, dynamic>{
      'authorization': _apiKeyHeader,
    });
    return result;
  }

  Future<PopularMovieResponse> popularMovies(int page, String locale) async {
    final parser = (dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    };

    final result = _get(
      '/movie/popular',
      parser,
      <String, dynamic>{'authorization': _apiKeyHeader},
      <String, dynamic>{'language': locale.toString(), 'page': page.toString()},
    );
    return result;
  }

  Future<PopularMovieResponse> searchMovie(
    int page,
    String locale,
    String query,
  ) async {
    final parser = (dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    };

    final result = _get(
      '/search/movie',
      parser,
      <String, dynamic>{'authorization': _apiKeyHeader},
      <String, dynamic>{
        'query': query,
        'include_adult': true.toString(),
        'language': locale.toString(),
        'page': page.toString(),
      },
    );
    return result;
  }

  Future<MovieDetails> movieDetails(int movieId, String locale) async {
    final parser = (dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = MovieDetails.fromJson(jsonMap);
      return response;
    };

    final result = _get(
      '/movie/$movieId',
      parser,
      <String, dynamic>{'authorization': _apiKeyHeader},
      <String, dynamic>{
        'language': locale.toString(),
        'append_to_response': 'credits',
      },
    );
    return result;
  }

  Future<String> _validateUser({
    required String username,
    required String password,
    required String requestToken,
  }) async {
    final parser = (dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token = jsonMap['request_token'] as String;
      return token;
    };

    final parameters = <String, dynamic>{
      'username': username,
      'password': password,
      'request_token': requestToken,
    };

    final result = _post(
      '/authentication/token/validate_with_login',
      parser,
      <String, dynamic>{'authorization': _apiKeyHeader},
      parameters,
    );
    return result;
  }

  Future<String> _makeSession({required String requestToken}) async {
    final parser = (dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final sessionId = jsonMap['session_id'] as String;
      return sessionId;
    };

    final parameters = <String, dynamic>{'request_token': requestToken};

    final result = _post(
      '/authentication/session/new',
      parser,
      <String, dynamic>{'authorization': _apiKeyHeader},
      parameters,
    );
    return result;
  }

  void _validateREsponse(HttpClientResponse response, dynamic json) {
    if (response.statusCode == 401) {
      final dynamic status = json['status_code'];
      final code = status is int ? status : 0;
      if (code == 30) {
        throw ApiClientException(ApiCLientExceptionType.auth);
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

/*
30

*/
