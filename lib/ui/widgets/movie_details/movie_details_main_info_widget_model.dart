import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

class MovieDetailsMainInfoWidgetModel extends ChangeNotifier {
  void onPlayTrailerTap(BuildContext context, String? trailerKey) {
    Navigator.of(context).pushNamed(
      MainNavigationRoutesName.movieTrailerWidget,
      arguments: trailerKey,
    );
  }
}
