//клиент для взаимодействия об аккаунте

import 'package:moviedb_app_llf/config/configuration.dart';
import 'package:moviedb_app_llf/domain/api_client/network_client.dart';

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

class AccountApiClient {
  final _networkClient = NetworkClient();

  Future<int> getAccountId(String sessionId) async {
    int parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['id'] as int;
      return result;
    }

    final result = _networkClient.get(
      '/account',
      parser,
      null,
      <String, dynamic>{
        'api_key': Configuration.apiKey,
        'session_id': sessionId,
      },
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
    int parser(dynamic json) {
      return 1;
    }

    final headers = <String, dynamic>{
      'authorization': Configuration.apiKeyHeader,
      'accept': 'application/json',
    };
    final bodyParameters = <String, dynamic>{
      'media_type': mediaType.asString(),
      'media_id': mediaId,
      'favorite': isFavorite,
    };
    final queryParameters = <String, dynamic>{'session_id': sessionId};

    final result = _networkClient.post(
      '/account/$accountId/favorite',
      parser,
      headers,
      bodyParameters,
      queryParameters,
    );
    return result;
  }
}
