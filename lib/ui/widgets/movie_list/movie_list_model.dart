import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviedb_app_llf/domain/api_client/api_client.dart';
import 'package:moviedb_app_llf/domain/entity/movie.dart';
import 'package:moviedb_app_llf/domain/entity/popular_movie_response.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

class MovieListModel extends ChangeNotifier {
  final _apiCLient = ApiClient();
  final _movies = <Movie>[];
  late int _currentPage;
  late int _totalPage;
  var _isLoadingInProgres = false;
  List<Movie> get movies => List.unmodifiable(_movies);
  late DateFormat _dateFomat;
  String _locale = '';
  String? _seacrhQuery;
  Timer? searchDeboubce;

  String stringFromDate(DateTime? date) =>
      date != null ? _dateFomat.format(date) : '';

  void setupLocale(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    //print(_locale);
    if (_locale == locale) return;
    _locale = locale;
    _dateFomat = DateFormat.yMMMd(locale);
    _resetList();
  }

  Future<void> _resetList() async {
    _currentPage = 0;
    _totalPage = 1;
    _movies.clear();
    await _loadNextPage();
  }

  Future<PopularMovieResponse> _loadMovies(int nextPage, String locale) async {
    final query = _seacrhQuery;
    if (query == null) {
      return await _apiCLient.popularMovies(nextPage, locale);
    } else {
      return await _apiCLient.searchMovie(nextPage, locale, query);
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingInProgres || _currentPage >= _totalPage) return;
    _isLoadingInProgres = true;
    final nextPage = _currentPage + 1;

    try {
      final moviesResponse = await _loadMovies(nextPage, _locale);
      _currentPage = moviesResponse.page;
      _totalPage = moviesResponse.totalPages;

      _movies.addAll(moviesResponse.movies);
      _isLoadingInProgres = false;
      notifyListeners();
    } catch (e) {
      _isLoadingInProgres = false;
    }
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
      await _resetList();
    });
  }

  void showedMovieAtIndex(int index) {
    // print(index);
    if (index < _movies.length - 1) return;
    _loadNextPage();
  }
}
