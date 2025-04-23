import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/domain/factoryes/screen_factory.dart';

import 'package:moviedb_app_llf/library/widgets/movie_trailer/movie_trailer.dart';

class MainNavigationRoutesName {
  static const auth = 'auth';
  static const mainScreen = '/mainc_screen';
  static const movieDetails = '/mainc_screen/movie_details';
  static const movieTrailerWidget = '/movie_details/trailers';
  static const loaderWidget = '/';
}

class MainNavigation {
  // делаем статик чтобы она появилась первее чем переменная routes
  static final _screenFactory = ScreenFactory();

  // роуты без параметеров
  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRoutesName.loaderWidget: (_) => _screenFactory.makeLoader(),
    MainNavigationRoutesName.auth: (_) => _screenFactory.makeAuth(),
    MainNavigationRoutesName.mainScreen: (_) => _screenFactory.makeMainScreen(),
  };
  // онГенерейтРоуты с переменными
  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRoutesName.movieDetails:
        final arguments = settings.arguments;
        final movieId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (_) => _screenFactory.makeMovieDetails(movieId),
        );
      case MainNavigationRoutesName.movieTrailerWidget:
        final arguments = settings.arguments;
        final youTubeKey = arguments is String ? arguments : '';
        return MaterialPageRoute(
          builder: (_) => MovieTrailerWidget(youTubeKey: youTubeKey),
        );
      default:
        const widget = Text('Navigation error');
        return MaterialPageRoute(builder: (_) => widget);
    }
  }
}
