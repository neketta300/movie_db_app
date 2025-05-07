import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviedb_app_llf/domain/entity/movie.dart';
import 'package:moviedb_app_llf/domain/services/movie_service.dart';
import 'package:moviedb_app_llf/domain/storage/localized_model_storage.dart';
import 'package:moviedb_app_llf/library/paginator.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

class MovieListRowData {
  final int id;
  final String? posterPath;
  final String title;
  final String releaseDate;
  final String overview;
  MovieListRowData({
    required this.id,
    required this.posterPath,
    required this.title,
    required this.releaseDate,
    required this.overview,
  });
}

class MovieListViewModel extends ChangeNotifier {
  final _movieApiService = MovieService();
  late final Paginator<Movie> _popularMoviePaginator;
  late final Paginator<Movie> _searchMoviePaginator;

  // таймер для паузы между запросами при поиске фильмов
  Timer? searchDeboubce;

  var _movies = <MovieListRowData>[];

  // внутри него конструктор который форматирует дату
  late DateFormat _dateFomat;
  String? _seacrhQuery;

  final _localStorage = LocalizedModelStorage();

  List<MovieListRowData> get movies => List.unmodifiable(_movies);

  bool get isSearchMode {
    final seacrhQuery = _seacrhQuery;
    return seacrhQuery != null && seacrhQuery.isNotEmpty;
  }

  MovieListViewModel() {
    _popularMoviePaginator = Paginator<Movie>((page) async {
      final result = await _movieApiService.popularMovies(
        page,
        _localStorage.localeTag,
      );
      return PaginatorLoadResult(
        data: result.movies,
        currentPage: result.page,
        totalPage: result.totalPages,
      );
    });
    _searchMoviePaginator = Paginator<Movie>((page) async {
      final result = await _movieApiService.searchMovie(
        page,
        _localStorage.localeTag,
        _seacrhQuery ?? '',
      );
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
    _resetList();
  }

  Future<void> _resetList() async {
    _movies.clear();
    await _popularMoviePaginator.reset();
    await _searchMoviePaginator.reset();
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (isSearchMode) {
      await _searchMoviePaginator.loadNextPage();
      _movies = _searchMoviePaginator.data.map(_makeRowData).toList();
    } else {
      await _popularMoviePaginator.loadNextPage();
      _movies = _popularMoviePaginator.data.map(_makeRowData).toList();
    }
    notifyListeners();
  }

  MovieListRowData _makeRowData(Movie movie) {
    final releaseDate = movie.releaseDate;
    final releaseDateTitle =
        releaseDate != null ? _dateFomat.format(releaseDate) : '';
    return MovieListRowData(
      id: movie.id,
      posterPath: movie.posterPath,
      title: movie.title,
      releaseDate: releaseDateTitle,
      overview: movie.overview,
    );
  }

  void onMovieTap(BuildContext context, int index) {
    final id = _movies[index].id;
    Navigator.of(
      context,
    ).pushNamed(MainNavigationRoutesName.movieDetails, arguments: id);
  }

  Future<void> searchMovie(String text) async {
    //print(text);
    searchDeboubce?.cancel();
    searchDeboubce = Timer(const Duration(milliseconds: 350), () async {
      final seacrhQuery = text.isNotEmpty ? text : null;
      if (_seacrhQuery == seacrhQuery) return;
      _seacrhQuery = seacrhQuery;

      _movies.clear();
      if (isSearchMode) {
        await _searchMoviePaginator.reset();
      }
      _loadNextPage();
    });
  }

  //загрузка следующей пачки фильмов при скроле списка
  void showedMovieAtIndex(int index) {
    // print(index);
    if (index < _movies.length - 1) return;
    _loadNextPage();
  }
}
