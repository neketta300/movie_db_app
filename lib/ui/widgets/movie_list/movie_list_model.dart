import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/domain/api_client/api_client.dart';
import 'package:moviedb_app_llf/domain/entity/movie.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

class MovieListModel extends ChangeNotifier {
  final _apiCLient = ApiClient();
  final _movies = <Movie>[];
  List<Movie> get movies => List.unmodifiable(_movies);

  Future<void> loadMovies() async {
    final moviesResponse = await _apiCLient.popularMovies(2, 'ru-RU');
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
