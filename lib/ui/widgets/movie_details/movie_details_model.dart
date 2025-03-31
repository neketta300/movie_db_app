// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:moviedb_app_llf/domain/api_client/api_client.dart';
import 'package:moviedb_app_llf/domain/entity/movie_details.dart';

class MovieDetailsModel extends ChangeNotifier {
  final _apiClient = ApiClient();

  final int movieId;
  late DateFormat _dateFomat;
  String _locale = '';
  MovieDetails? _movieDetails;

  MovieDetails? get movieDetails => _movieDetails;

  MovieDetailsModel({required this.movieId});

  Future<void> setUpLocale(BuildContext context) async {
    final locale = Localizations.localeOf(context).toLanguageTag();
    //print(_locale);
    if (_locale == locale) return;
    _locale = locale;
    _dateFomat = DateFormat.yMMMd(locale);
    await loadDetails();
  }

  String stringFromDate(DateTime? date) =>
      date != null ? _dateFomat.format(date) : '';

  Future<void> loadDetails() async {
    _movieDetails = await _apiClient.movieDetails(movieId, _locale);
    notifyListeners();
  }
}
