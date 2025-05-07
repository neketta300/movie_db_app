import 'package:moviedb_app_llf/config/configuration.dart';
import 'package:moviedb_app_llf/domain/api_client/account_api_client.dart';
import 'package:moviedb_app_llf/domain/api_client/movie_api_client.dart';
import 'package:moviedb_app_llf/domain/data_providers/session_data_provider.dart';
import 'package:moviedb_app_llf/domain/entity/popular_movie_response.dart';
import 'package:moviedb_app_llf/domain/local_entity/movie_details_local.dart';

class MovieService {
  final _sessionDataProvider = SessionDataProvider();
  final _movieApiClient = MovieApiClient();
  final _accountApiClient = AccountApiClient();
  final _moiveApiClient = MovieApiClient();
  Future<PopularMovieResponse> upcomingMovies(int page, String locale) async =>
      _moiveApiClient.upcomingMovies(page, locale, Configuration.apiKeyHeader);
  Future<PopularMovieResponse> freeMovies(int page, String locale) async =>
      _moiveApiClient.freeMovies(page, locale, Configuration.apiKeyHeader);
  Future<PopularMovieResponse> popularMovies(int page, String locale) async =>
      _moiveApiClient.popularMovies(page, locale, Configuration.apiKeyHeader);
  Future<PopularMovieResponse> nowPlayingMovies(
    int page,
    String locale,
  ) async => _moiveApiClient.nowPlayingMovies(
    page,
    locale,
    Configuration.apiKeyHeader,
  );

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

  Future<MovieDetailsLocal> loadDetails({
    required int movieId,
    required String locale,
  }) async {
    final movieDetails = await _movieApiClient.movieDetails(movieId, locale);
    final sessionId = await _sessionDataProvider.getSessionId();
    var isFavorite = false;
    if (sessionId != null) {
      isFavorite = await _movieApiClient.isFilmFavorite(movieId, sessionId);
    }
    return MovieDetailsLocal(details: movieDetails, isFavorite: isFavorite);
  }

  Future<void> updateFavorite({
    required int movieId,
    required bool isFavorite,
  }) async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final accountId = await _sessionDataProvider.getAccountId();
    if (accountId == null || sessionId == null) return;

    await _accountApiClient.addFavorite(
      accountId: accountId,
      sessionId: sessionId,
      mediaType: MediaType.movie,
      mediaId: movieId,
      isFavorite: isFavorite,
    );
  }
}
