import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviedb_app_llf/domain/api_client/api_client.dart';
import 'package:moviedb_app_llf/domain/entity/movie.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

class MovieListModel extends ChangeNotifier {
  final _apiCLient = ApiClient();
  final _movies = <Movie>[];
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
    _movies.clear();
    loadMovies();
    print(_locale);
  }

  Future<void> loadMovies() async {
    final moviesResponse = await _apiCLient.popularMovies(2, _locale);
    _movies.addAll(moviesResponse.movies);
    notifyListeners();
  }

  void onMovieTap(BuildContext context, int index) {
    final id = _movies[index].id;
    Navigator.of(
      context,
    ).pushNamed(MainNavigationRoutesName.movieDetails, arguments: id);
  }
}
