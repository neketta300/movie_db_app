import 'package:moviedb_app_llf/config/configuration.dart';
import 'package:moviedb_app_llf/domain/api_client/movie_api_client.dart';
import 'package:moviedb_app_llf/domain/entity/popular_movie_response.dart';

class MovieService {
  final _moiveApiClient = MovieApiClient();
  Future<PopularMovieResponse> popularMovies(int page, String locale) async =>
      _moiveApiClient.popularMovies(page, locale, Configuration.apiKeyHeader);

  Future<PopularMovieResponse> searchMovie(
    int page,
    String locale,
    String query,
  ) async => _moiveApiClient.searchMovie(
    page,
    locale,
    query,
    Configuration.apiKeyHeader,
  );
}
