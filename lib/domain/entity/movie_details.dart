import 'package:json_annotation/json_annotation.dart';
import 'package:moviedb_app_llf/domain/entity/movie_date_parser.dart';
import 'package:moviedb_app_llf/domain/entity/movie_details_credits.dart';
import 'package:moviedb_app_llf/domain/entity/movie_details_videos.dart';

part 'movie_details.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
) // explicitToJson для вложенных классов
class MovieDetails {
  final bool adult;
  final String? backdropPath;
  final Map<String, dynamic>? belongsToCollection;
  final int budget;
  final List<Genre> genres;
  final String? homepage;
  final int id;
  final String? imdbId;
  final String originalLanguage;
  final String originalTitle;
  final String? overview;
  final double popularity;
  final String? posterPath;
  final List<ProductionCompanie> productionCompanies;
  final List<ProductionCountrie> productionCountries;
  @JsonKey(fromJson: parseDateFromString)
  final DateTime? releaseDate;
  final int revenue;
  final int? runtime;
  final List<SpokenLanguage> spokenLanguages;
  final String status;
  final String? tagline;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;
  final MovieDetailsCredits credits;
  final MovieDetailsVideos videos;
  MovieDetails({
    required this.videos,
    required this.credits,
    required this.adult,
    required this.backdropPath,
    required this.belongsToCollection,
    required this.budget,
    required this.genres,
    required this.homepage,
    required this.id,
    required this.imdbId,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    required this.releaseDate,
    required this.revenue,
    required this.runtime,
    required this.spokenLanguages,
    required this.status,
    required this.tagline,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$MovieDetailsToJson(this);
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
) // fieldRename: FieldRename.snake чтобы полученые поля в формате name_sndname были в nameScndname
class Genre {
  final int id;
  final String name;
  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  Map<String, dynamic> toJson() => _$GenreToJson(this);
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
) // fieldRename: FieldRename.snake чтобы полученые поля в формате name_sndname были в nameScndname
class ProductionCompanie {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;
  ProductionCompanie({
    required this.id,
    required this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory ProductionCompanie.fromJson(Map<String, dynamic> json) =>
      _$ProductionCompanieFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionCompanieToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake) // зм
class ProductionCountrie {
  @JsonKey(name: 'iso_3166_1')
  final String iso;
  final String name;
  ProductionCountrie({required this.iso, required this.name});
  factory ProductionCountrie.fromJson(Map<String, dynamic> json) =>
      _$ProductionCountrieFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionCountrieToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake) // зм
class SpokenLanguage {
  final String englishName;
  @JsonKey(name: 'iso_639_1')
  final String iso;
  final String name;
  SpokenLanguage({
    required this.englishName,
    required this.iso,
    required this.name,
  });

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) =>
      _$SpokenLanguageFromJson(json);

  Map<String, dynamic> toJson() => _$SpokenLanguageToJson(this);
}
