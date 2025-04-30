// клиент для работы с фильмами

import 'package:moviedb_app_llf/config/configuration.dart';
import 'package:moviedb_app_llf/domain/api_client/network_client.dart';
import 'package:moviedb_app_llf/domain/entity/movie_details.dart';
import 'package:moviedb_app_llf/domain/entity/popular_movie_response.dart';

class MovieApiClient {
  final _networkClient = NetworkClient();

  Future<PopularMovieResponse> popularMovies(
    int page,
    String locale,
    String apiKeyHeader,
  ) async {
    PopularMovieResponse parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }

    final result = _networkClient.get(
      '/movie/popular',
      parser,
      <String, dynamic>{'Authorization': apiKeyHeader},
      <String, dynamic>{'language': locale.toString(), 'page': page.toString()},
    );
    return result;
  }

  Future<PopularMovieResponse> searchMovie(
    int page,
    String locale,
    String query,
    String apiKeyHeader,
  ) async {
    PopularMovieResponse parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }

    final result = _networkClient.get(
      '/search/movie',
      parser,
      <String, dynamic>{'Authorization': apiKeyHeader},
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
    MovieDetails parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = MovieDetails.fromJson(jsonMap);
      return response;
    }

    final result = _networkClient.get(
      '/movie/$movieId',
      parser,
      <String, dynamic>{'Authorization': Configuration.apiKeyHeader},
      <String, dynamic>{
        'language': locale.toString(),
        'append_to_response': 'videos,credits',
      },
    );
    return result;
  }

  Future<bool> isFilmFavorite(int movieId, String sessionId) async {
    bool parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['favorite'] as bool;
      return result;
    }

    final result = _networkClient.get(
      '/movie/$movieId/account_states',
      parser,
      <String, dynamic>{'authorization': Configuration.apiKeyHeader},
      <String, dynamic>{'sessio_id': sessionId},
    );
    return result;
  }
}
