import 'package:moviedb_app_llf/library/widgets/inherited/provider.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_main_info_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_main_screen_cast_widget.dart';
import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_model.dart';

class MovieDetailsWidget extends StatefulWidget {
  const MovieDetailsWidget({super.key});

  @override
  _MovieDetailsWidgetState createState() => _MovieDetailsWidgetState();
}

class _MovieDetailsWidgetState extends State<MovieDetailsWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NotifierProvider.read<MovieDetailsModel>(context)?.setUpLocale(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _TitleWidget(), centerTitle: true),
      body: const ColoredBox(
        color: Color.fromRGBO(24, 23, 27, 1.0),
        child: _BodyWidget(),
      ),
    );
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget();

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    final movieDetails = model?.movieDetails;
    if (movieDetails == null) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        const MovieDetailsMainInfoWidget(),
        const SizedBox(height: 30),
        const MovieDetailsMainScreenCastWidget(),
      ],
    );
  }
}

// вынес текст в отдельный виджет чтобы при изменении назвнаие перезагружался только этот вижет а не весь (MovieDetailsWidget)
class _TitleWidget extends StatelessWidget {
  const _TitleWidget();

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    return Text(
      model?.movieDetails?.title ?? 'Загрузка...',
      style: TextStyle(color: Colors.white),
    );
  }
}
