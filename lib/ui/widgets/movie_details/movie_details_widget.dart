import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_main_info_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_main_screen_cast_widget.dart';
import 'package:flutter/material.dart';

class MovieDetailsWidget extends StatefulWidget {
  final int movieId;

  const MovieDetailsWidget({super.key, required this.movieId});

  @override
  _MovieDetailsWidgetState createState() => _MovieDetailsWidgetState();
}

class _MovieDetailsWidgetState extends State<MovieDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tom Clancy`s Without Remorse')),
      body: ColoredBox(
        color: const Color.fromRGBO(24, 23, 27, 1.0),
        child: ListView(
          children: [
            const MovieDetailsMainInfoWidget(),
            const SizedBox(height: 30),
            const MovieDetailsMainScreenCastWidget(),
          ],
        ),
      ),
    );
  }
}
