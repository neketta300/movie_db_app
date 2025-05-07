// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:moviedb_app_llf/domain/entity/movie.dart';

import 'package:moviedb_app_llf/domain/entity/popular_movie_response.dart';
import 'package:moviedb_app_llf/domain/services/movie_service.dart';
import 'package:moviedb_app_llf/domain/storage/localized_model_storage.dart';
import 'package:moviedb_app_llf/library/paginator.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

enum MovieListType { popular, free, trending }

class NewsFilmData {
  final int id;
  final String? posterPath;
  final String title;
  final String releaseDate;
  final double voteAverage;
  NewsFilmData({
    required this.id,
    this.posterPath,
    required this.title,
    required this.releaseDate,
    required this.voteAverage,
  });
}

class NewsTrailerData {
  final String? trailersKey;

  NewsTrailerData({required this.trailersKey});
}

class NewsData {
  NewsTrailerData trailerKey = NewsTrailerData(trailersKey: '');
  NewsFilmData filmData = NewsFilmData(
    id: 0,
    title: '',
    releaseDate: '',
    voteAverage: 0,
  );
  NewsData({required this.trailerKey, required this.filmData});
}

class NewsViewModel extends ChangeNotifier {
  final _movieApiService = MovieService();
  // внутри него конструктор который форматирует дату
  late DateFormat _dateFomat;
  final _localStorage = LocalizedModelStorage();

  // лист пагинторов
  final _moviePaginators = <MovieListType, Paginator<Movie>>{};
  final _trailers = <String?>[];
  String? _backgroundPosterPath;

  //лист листов списков фильмов
  final _movies = <MovieListType, List<NewsData>>{
    MovieListType.popular: [],
    MovieListType.free: [],
    MovieListType.trending: [],
  };

  List<String?> get trailers => _trailers;
  String? get backgroundPosterPath => _backgroundPosterPath;
  List<NewsData> get popularMovies =>
      List.unmodifiable(_movies[MovieListType.popular] ?? []);

  List<NewsData> get freeMovies =>
      List.unmodifiable(_movies[MovieListType.free] ?? []);

  List<NewsData> get trendingMovies =>
      List.unmodifiable(_movies[MovieListType.trending] ?? []);

  NewsViewModel() {
    _initPaginator(MovieListType.popular, _movieApiService.popularMovies);
    _initPaginator(MovieListType.free, _movieApiService.upcomingMovies);
    _initPaginator(MovieListType.trending, _movieApiService.nowPlayingMovies);
  }

  void _initPaginator(
    MovieListType type,
    Future<PopularMovieResponse> Function(int page, String locale) apiCall,
  ) {
    _moviePaginators[type] = Paginator<Movie>((page) async {
      final result = await apiCall(page, _localStorage.localeTag);
      return PaginatorLoadResult(
        data: result.movies,
        currentPage: result.page,
        totalPage: result.totalPages,
      );
    });
  }

  void setupLocale(Locale locale) {
    if (!_localStorage.updateLocale(locale)) return;
    _dateFomat = DateFormat.yMMMd(_localStorage.localeTag);
    _resetAllList();
  }

  NewsData _makeRowData(Movie movie) {
    // final videos = movie.videos.results.where(
    //   (video) => video.type == 'Trailer' && video.site == 'YouTube',
    // );
    // final trailerKey = videos.isNotEmpty == true ? videos.first.key : null;
    final releaseDate = movie.releaseDate;
    final releaseDateTitle =
        releaseDate != null ? _dateFomat.format(releaseDate) : '';
    NewsFilmData filmData = NewsFilmData(
      id: movie.id,
      title: movie.title,
      releaseDate: releaseDateTitle,
      voteAverage: movie.voteAverage,
      posterPath: movie.posterPath,
    );
    NewsTrailerData trailerData = NewsTrailerData(trailersKey: 'trailerKey');
    return NewsData(trailerKey: trailerData, filmData: filmData);
  }

  Future<void> _resetAllList() async {
    _movies.forEach((key, value) => value.clear());
    await _moviePaginators[MovieListType.popular]?.reset();
    await _moviePaginators[MovieListType.trending]?.reset();
    await _moviePaginators[MovieListType.free]?.reset();
    await _loadAllNextPage();
    _loadTrailers();
  }

  void onMovieTap(BuildContext context, int index, MovieListType type) {
    final movieId = _movies[type]?[index].filmData.id ?? 0;
    Navigator.of(
      context,
    ).pushNamed(MainNavigationRoutesName.movieDetails, arguments: movieId);
  }

  Future<void> _loadAllNextPage() async {
    await _loadNextPage(MovieListType.popular);
    await _loadNextPage(MovieListType.free);
    await _loadNextPage(MovieListType.trending);
    notifyListeners();
  }

  Future<void> _loadNextPage(MovieListType type) async {
    final paginator = _moviePaginators[type];
    if (paginator == null) return;

    await paginator.loadNextPage();
    _movies[type] = paginator.data.map(_makeRowData).toList();
    notifyListeners();
  }

  void showedMovieAtIndex(int index, MovieListType type) {
    final movies = _movies[type];
    if (index < movies!.length - 1) return;
    _loadNextPage(type);
  }

  void _loadBackgroundPosterPath() {
    final trendingMovies = _movies[MovieListType.trending];
    if (trendingMovies != null && trendingMovies.isNotEmpty) {
      _backgroundPosterPath = trendingMovies.first.filmData.posterPath;
    } else {
      _backgroundPosterPath = null;
    }
    notifyListeners();
  }

  void _loadTrailers() {
    _trailers.clear();
    _movies[MovieListType.trending]?.forEach((movie) {
      _trailers.add(movie.trailerKey.trailersKey);
    });
    _loadBackgroundPosterPath();
    notifyListeners();
  }

  void onPlayTrailerTap(BuildContext context, String? trailerKey) {
    Navigator.of(context).pushNamed(
      MainNavigationRoutesName.movieTrailerWidget,
      arguments: trailerKey,
    );
  }
}
