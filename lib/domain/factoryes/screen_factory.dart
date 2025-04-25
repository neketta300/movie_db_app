import 'package:flutter/widgets.dart';
import 'package:moviedb_app_llf/library/widgets/inherited/provider.dart'
    as old_provider;
import 'package:moviedb_app_llf/library/widgets/movie_trailer/movie_trailer.dart';
import 'package:moviedb_app_llf/ui/widgets/auth/auth_model.dart';
import 'package:moviedb_app_llf/ui/widgets/auth/auth_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/loader_widget/loader_view_model.dart';
import 'package:moviedb_app_llf/ui/widgets/loader_widget/loader_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/main_screen/main_screen_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_model.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_widget.dart';
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
    return old_provider.NotifierProvider(
      create: () => MovieDetailsModel(movieId: movieId),
      child: MovieDetailsWidget(),
    );
  }

  Widget makeMovieTrailer(String youTubeKey) =>
      MovieTrailerWidget(youTubeKey: youTubeKey);
}
