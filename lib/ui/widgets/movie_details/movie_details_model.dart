import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviedb_app_llf/domain/api_client/api_client_exception.dart';
import 'package:moviedb_app_llf/domain/entity/movie_details.dart';
import 'package:moviedb_app_llf/domain/services/auth_service.dart';
import 'package:moviedb_app_llf/domain/services/movie_service.dart';
import 'package:moviedb_app_llf/domain/storage/localized_model_storage.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

class MovieDetailsActorData {
  final String name;
  final String character;
  final String? profilePath;

  MovieDetailsActorData({
    required this.name,
    required this.character,
    this.profilePath,
  });
}

class MovieDetailsPosterData {
  final String? backdropPath;
  final String? posterPath;
  IconData get favoriteIcon =>
      isFavorite ? Icons.favorite : Icons.favorite_outline;
  final bool isFavorite;
  MovieDetailsPosterData({
    this.backdropPath,
    this.posterPath,
    this.isFavorite = false,
  });

  MovieDetailsPosterData copyWith({
    String? backdropPath,
    String? posterPath,
    bool? isFavorite,
  }) {
    return MovieDetailsPosterData(
      backdropPath: backdropPath ?? this.backdropPath,
      posterPath: posterPath ?? this.posterPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class MovieDetailsNameData {
  final String name;
  final String year;

  MovieDetailsNameData({required this.name, required this.year});
}

class MovieDetailsPeopleData {
  final String job;
  final String name;

  MovieDetailsPeopleData({required this.job, required this.name});
}

class MovieDetailsScoreData {
  final String? trailerKey;
  final double voteAverage;
  MovieDetailsScoreData({this.trailerKey, required this.voteAverage});
}

// класс нужен для того что будет храниться на экране
class MovieDetailsData {
  String title = '';
  String overview = '';
  bool isLoading = true;
  MovieDetailsPosterData posterData = MovieDetailsPosterData();
  MovieDetailsNameData nameData = MovieDetailsNameData(name: '', year: '');
  MovieDetailsScoreData scoreData = MovieDetailsScoreData(voteAverage: 0);
  String summary = '';
  List<List<MovieDetailsPeopleData>> peopleData =
      const <List<MovieDetailsPeopleData>>[];
  List<MovieDetailsActorData> actorsData = const <MovieDetailsActorData>[];
}

class MovieDetailsModel extends ChangeNotifier {
  final _authService = AuthService();
  final _movieService = MovieService();

  final data = MovieDetailsData();
  final int movieId;
  late DateFormat _dateFomat;
  final _localStorage = LocalizedModelStorage();

  MovieDetailsModel({required this.movieId});

  Future<void> setUpLocale(BuildContext context, Locale locale) async {
    if (!_localStorage.updateLocale(locale)) return;
    //print(_locale);
    _dateFomat = DateFormat.yMMMd(_localStorage.localeTag);
    updateData(null, false);
    await loadDetails(context);
  }

  void updateData(MovieDetails? details, bool isFavorite) {
    data.title = details?.title ?? 'Загрузка...';
    data.isLoading = details == null;
    if (details == null) {
      notifyListeners();
      return;
    }
    data.overview = details.overview ?? '';

    data.posterData = MovieDetailsPosterData(
      backdropPath: details.backdropPath,
      posterPath: details.posterPath,
      isFavorite: isFavorite,
    );
    var year = details.releaseDate?.year.toString();
    year = year != null ? ' ($year)' : '';
    data.nameData = MovieDetailsNameData(name: details.title, year: year);
    final videos = details.videos.results.where(
      (video) => video.type == 'Trailer' && video.site == 'YouTube',
    );
    final trailerKey = videos.isNotEmpty == true ? videos.first.key : null;
    data.scoreData = MovieDetailsScoreData(
      voteAverage: details.voteAverage * 10,
      trailerKey: trailerKey,
    );
    data.summary = makeSummary(details);
    data.peopleData = makePeopleData(details);
    data.actorsData =
        details.credits.cast!
            .map(
              (e) => MovieDetailsActorData(
                name: e.name,
                character: e.character,
                profilePath: e.profilePath,
              ),
            )
            .toList();
    notifyListeners();
  }

  String makeSummary(MovieDetails details) {
    var texts = <String>[];
    final releaseDate = details.releaseDate;
    if (releaseDate != null) {
      texts.add(_dateFomat.format(releaseDate));
    }

    if (details.productionCountries.isNotEmpty) {
      texts.add('(${details.productionCountries.first.iso})');
    }
    final runtime = details.runtime ?? 0;
    final duration = Duration(minutes: runtime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    texts.add('${hours}h ${minutes}m');

    if (details.genres.isNotEmpty) {
      var genresName = <String>[];
      for (var genr in details.genres) {
        genresName.add(genr.name);
      }
      texts.add(genresName.join(', '));
    }
    return texts.join(' ');
  }

  List<List<MovieDetailsPeopleData>> makePeopleData(MovieDetails details) {
    var crew =
        details.credits.crew
            .map((e) => MovieDetailsPeopleData(job: e.job, name: e.name))
            .toList();
    crew = crew.length > 4 ? crew.sublist(0, 4) : crew;
    var crewChunks = <List<MovieDetailsPeopleData>>[];
    for (var i = 0; i < crew.length; i += 2) {
      crewChunks.add(
        crew.sublist(i, i + 2 > crew.length ? crew.length : i + 2),
      );
    }
    return crewChunks;
  }

  Future<void> loadDetails(BuildContext context) async {
    try {
      final movieDetails = await _movieService.loadDetails(
        movieId: movieId,
        locale: _localStorage.localeTag,
      );
      updateData(movieDetails.details, movieDetails.isFavorite);
    } on ApiClientException catch (e) {
      _handleApiClientException(e, context);
    }
  }

  Future<void> toggleFavorite(BuildContext context) async {
    data.posterData = data.posterData.copyWith(
      isFavorite: !data.posterData.isFavorite,
    );
    notifyListeners();
    try {
      await _movieService.updateFavorite(
        isFavorite: data.posterData.isFavorite,
        movieId: movieId,
      );
    } on ApiClientException catch (e) {
      _handleApiClientException(e, context);
    }
  }

  void _handleApiClientException(
    ApiClientException execption,
    BuildContext context,
  ) {
    switch (execption.type) {
      case ApiCLientExceptionType.sessionExpired:
        _authService.logout();
        MainNavigation.resetNavigation(context);
        break;
      default:
        print(execption);
    }
  }
}
