// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:moviedb_app_llf/domain/api_client/api_client.dart';
import 'package:moviedb_app_llf/domain/data_providers/session_data_provider.dart';
import 'package:moviedb_app_llf/domain/entity/movie_details.dart';

class MovieDetailsModel extends ChangeNotifier {
  final _sessionDataProvider = SessionDataProvider();
  final _apiClient = ApiClient();

  final int movieId;
  late DateFormat _dateFomat;
  String _locale = '';
  MovieDetails? _movieDetails;
  bool _isFavorite = false;

  Future<void>? Function()? onSessionExpired;

  MovieDetails? get movieDetails => _movieDetails;
  bool get isFavorite => _isFavorite;

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
    try {
      _movieDetails = await _apiClient.movieDetails(movieId, _locale);
      final sessionId = await _sessionDataProvider.getSessionId();
      if (sessionId != null) {
        _isFavorite = await _apiClient.isFilmFavorite(movieId, sessionId);
      }
      notifyListeners();
    } on ApiClientException catch (e) {
      switch (e.type) {
        case ApiCLientExceptionType.sessionExpired:
          await onSessionExpired?.call();
          break;

        default:
          print(e);
      }
    }
  }

  Future<void> toggleFavorite() async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final accountId = await _sessionDataProvider.getAccountId();
    try {
      if (accountId == null || sessionId == null) return;
      _isFavorite = !_isFavorite;
      notifyListeners();
      await _apiClient.addFavorite(
        accountId: accountId,
        sessionId: 'sessionId',
        mediaType: MediaType.movie,
        mediaId: movieId,
        isFavorite: _isFavorite,
      );
    } on ApiClientException catch (e) {
      switch (e.type) {
        case ApiCLientExceptionType.sessionExpired:
          await onSessionExpired?.call();
          break;

        default:
          print(e);
      }
    }
  }
}
