import 'package:flutter/widgets.dart';
import 'package:moviedb_app_llf/library/widgets/movie_trailer/movie_trailer.dart';
import 'package:moviedb_app_llf/ui/widgets/auth/auth_model.dart';
import 'package:moviedb_app_llf/ui/widgets/auth/auth_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/loader_widget/loader_view_model.dart';
import 'package:moviedb_app_llf/ui/widgets/loader_widget/loader_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/main_screen/main_screen_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_model.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_list/movie_list_model.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_list/movie_list_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/news/news_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/tv_show_list/tv_show_list_widget.dart';
import 'package:provider/provider.dart';

class ScreenFactory {
  Widget makeLoader() {
    return Provider(
      create: (context) => LoaderViewModel(context),
      lazy: false,
      child: const LoaderWidget(),
    );
  }

  Widget makeAuth() {
    return ChangeNotifierProvider(
      create: (_) => AuthModel(),
      child: const AuthWidget(),
    );
  }

  Widget makeMainScreen() => const MainScreenWidget();

  Widget makeMovieDetails(int movieId) {
    return ChangeNotifierProvider(
      create: (_) => MovieDetailsModel(movieId: movieId),
      child: MovieDetailsWidget(),
    );
  }

  Widget makeMovieTrailer(String youTubeKey) =>
      MovieTrailerWidget(youTubeKey: youTubeKey);

  Widget makeNewsList() => const NewsWidget();

  Widget makeMovieList() {
    return ChangeNotifierProvider(
      create: (_) => MovieListViewModel(),
      child: const MovieListWidget(),
    );
  }

  Widget makeTWShowList() => const TWShowListWidget();
}
