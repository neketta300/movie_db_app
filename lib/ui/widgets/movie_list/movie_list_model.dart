import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviedb_app_llf/domain/api_client/api_client.dart';
import 'package:moviedb_app_llf/domain/entity/movie.dart';
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

  String stringFromDate(DateTime? date) =>
      date != null ? _dateFomat.format(date) : '';

  void setupLocale(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    print(_locale);
    if (_locale == locale) return;
    _locale = locale;
    _dateFomat = DateFormat.yMMMd(locale);
    _currentPage = 0;
    _totalPage = 1;
    _movies.clear();
    _loadMovies();
    print(_locale);
  }

  Future<void> _loadMovies() async {
    if (_isLoadingInProgres || _currentPage >= _totalPage) return;
    _isLoadingInProgres = true;
    final nextPage = _currentPage + 1;

    try {
      final moviesResponse = await _apiCLient.popularMovies(nextPage, _locale);
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

  void showedMovieAtIndex(int index) {
    print(index);
    if (index < _movies.length - 1) return;
    _loadMovies();
  }
}
