import 'dart:convert';
import 'dart:io';

import 'package:moviedb_app_llf/domain/entity/movie_details.dart';
import 'package:moviedb_app_llf/domain/entity/popular_movie_response.dart';

enum ApiCLientExceptionType { network, auth, other, sessionExpired }

class ApiClientException implements Exception {
  final ApiCLientExceptionType type;

  ApiClientException(this.type);
}

enum MediaType { movie, tv }

extension MediaTypeAsString on MediaType {
  String asString() {
    switch (this) {
      case MediaType.movie:
        return 'movie';
      case MediaType.tv:
        return 'tv';
    }
  }
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

  Uri _makeUri(String path, [Map<String, dynamic>? queryParameters]) {
    final uri = Uri.parse('$_host$path');
    if (queryParameters != null) {
      return uri.replace(queryParameters: queryParameters);
    } else {
      return uri;
    }
  }

  Future<T> _get<T>(
    String path,
    T Function(dynamic json) parser, [
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  ]) async {
    final url = _makeUri(path, queryParameters);
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

  Future<T> _post<T>(
    String path,
    T Function(dynamic json) parser,
    Map<String, dynamic> headers,
    Map<String, dynamic> bodyParameters, [
    Map<String, dynamic>? queryParameters,
  ]) async {
    final url = _makeUri(path, queryParameters);
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

  Future<int> getAccountId(String sessionId) async {
    final parser = (dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['id'] as int;
      return result;
    };

    final result = _get('/account', parser, null, <String, dynamic>{
      'api_key': _apiKey,
      'session_id': sessionId,
    });
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
        'append_to_response': 'videos,credits',
      },
    );
    return result;
  }

  Future<bool> isFilmFavorite(int movieId, String sessionId) async {
    final parser = (dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['favorite'] as bool;
      return result;
    };

    final result = _get(
      '/movie/$movieId/account_states',
      parser,
      <String, dynamic>{'authorization': _apiKeyHeader},
      <String, dynamic>{'sessio_id': sessionId},
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

    final bodyParameters = <String, dynamic>{
      'username': username,
      'password': password,
      'request_token': requestToken,
    };

    final result = _post(
      '/authentication/token/validate_with_login',
      parser,
      <String, dynamic>{'authorization': _apiKeyHeader},
      bodyParameters,
    );
    return result;
  }

  Future<int> addFavorite({
    required int accountId,
    required String sessionId,
    required MediaType mediaType,
    required int mediaId,
    required bool isFavorite,
  }) async {
    final parser = (dynamic json) {
      return 1;
    };

    final headers = <String, dynamic>{
      'authorization': _apiKeyHeader,
      'accept': 'application/json',
    };
    final bodyParameters = <String, dynamic>{
      'media_type': mediaType.asString(),
      'media_id': mediaId,
      'favorite': isFavorite,
    };
    final queryParameters = <String, dynamic>{'session_id': sessionId};

    final result = _post(
      '/account/$accountId/favorite',
      parser,
      headers,
      bodyParameters,
      queryParameters,
    );
    return result;
  }

  Future<String> _makeSession({required String requestToken}) async {
    final parser = (dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final sessionId = jsonMap['session_id'] as String;
      return sessionId;
    };

    final bodyParameters = <String, dynamic>{'request_token': requestToken};

    final result = _post(
      '/authentication/session/new',
      parser,
      <String, dynamic>{'authorization': _apiKeyHeader},
      bodyParameters,
    );
    return result;
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

/*
30

*/
