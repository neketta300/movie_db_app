import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/library/widgets/inherited/provider.dart';
import 'package:moviedb_app_llf/library/widgets/movie_trailer/movie_trailer.dart';
import 'package:moviedb_app_llf/ui/widgets/auth/auth_model.dart';
import 'package:moviedb_app_llf/ui/widgets/auth/auth_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/main_screen/main_screen_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_model.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_widget.dart';

class MainNavigationRoutesName {
  static const auth = 'auth';
  static const mainScreen = '/';
  static const movieDetails = '/movie_details';
  static const movieTrailerWidget = '/movie_details/trailers';
}

class MainNavigation {
  String initialRoute(bool isAuth) =>
      isAuth
          ? MainNavigationRoutesName.mainScreen
          : MainNavigationRoutesName.auth;

  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRoutesName.auth:
        (context) => NotifierProvider(
          create: () => AuthModel(),
          child: const AuthWidget(),
        ),
    MainNavigationRoutesName.mainScreen: (context) => const MainScreenWidget(),
  };

  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRoutesName.movieDetails:
        final arguments = settings.arguments;
        final movieId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder:
              (context) => NotifierProvider(
                create: () => MovieDetailsModel(movieId: movieId),
                child: MovieDetailsWidget(),
              ),
        );
      case MainNavigationRoutesName.movieTrailerWidget:
        final arguments = settings.arguments;
        final youTubeKey = arguments is String ? arguments : '';
        return MaterialPageRoute(
          builder: (context) => MovieTrailerWidget(youTubeKey: youTubeKey),
        );
      default:
        const widget = Text('Navigation error');
        return MaterialPageRoute(builder: (context) => widget);
    }
  }
}
