import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:moviedb_app_llf/domain/api_client/movie_api_client.dart';
import 'package:moviedb_app_llf/domain/entity/movie.dart';
import 'package:moviedb_app_llf/domain/entity/popular_movie_response.dart';
import 'package:moviedb_app_llf/domain/services/movie_service.dart';
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
  String _locale = '';

  Timer? searchDeboubce; // таймер для паузы между запросами при поиске фильмов

  var _movies = <MovieListRowData>[];
  late DateFormat _dateFomat;
  String? _seacrhQuery;

  List<MovieListRowData> get movies => List.unmodifiable(_movies);

  bool get isSearchMode {
    final seacrhQuery = _seacrhQuery;
    return seacrhQuery != null && seacrhQuery.isNotEmpty;
  }

  MovieListViewModel() {
    _popularMoviePaginator = Paginator<Movie>((page) async {
      final result = await _movieApiService.popularMovies(page, _locale);
      return PaginatorLoadResult(
        data: result.movies,
        currentPage: result.page,
        totalPage: result.totalPages,
      );
    });
    _searchMoviePaginator = Paginator<Movie>((page) async {
      final result = await _movieApiService.searchMovie(
        page,
        _locale,
        _seacrhQuery ?? '',
      );
      return PaginatorLoadResult(
        data: result.movies,
        currentPage: result.page,
        totalPage: result.totalPages,
      );
    });
  }

  void setupLocale(BuildContext context) {
    final locale =
        Localizations.localeOf(
          context,
        ).toLanguageTag(); // подписывается на измемениние локали устройства
    //print(_locale);
    if (_locale == locale) return;
    _locale = locale;
    _dateFomat = DateFormat.yMMMd(locale);
    _resetList();
  }

  Future<void> _resetList() async {
    _movies.clear();
    await _popularMoviePaginator.reset();
    await _searchMoviePaginator.reset();
    await _loadNextPage();

    final query = _seacrhQuery;
    if (query == null) {
    } else {}
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
    // if (_isLoadingInProgres || _currentPage >= _totalPage) return;
    // _isLoadingInProgres = true;
    // final nextPage = _currentPage + 1;

    // try {
    //   final moviesResponse = await _loadMovies(nextPage, _locale);
    //   _currentPage = moviesResponse.page;
    //   _totalPage = moviesResponse.totalPages;

    //   _movies.addAll(moviesResponse.movies.map(_makeRowData).toList());
    //   _isLoadingInProgres = false;
    //   notifyListeners();
    // } catch (e) {
    //   _isLoadingInProgres = false;
    // }
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

  void showedMovieAtIndex(int index) {
    // print(index);
    if (index < _movies.length - 1) return;
    _loadNextPage();
  }
}
