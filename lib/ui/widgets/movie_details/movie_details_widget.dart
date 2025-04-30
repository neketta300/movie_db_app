import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_main_info_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_main_info_widget_model.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_main_screen_cast_widget.dart';
import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_model.dart';
import 'package:provider/provider.dart';

class MovieDetailsWidget extends StatefulWidget {
  const MovieDetailsWidget({super.key});

  @override
  _MovieDetailsWidgetState createState() => _MovieDetailsWidgetState();
}

class _MovieDetailsWidgetState extends State<MovieDetailsWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // делается не сразу а на следующем витке iventloop
    // то есть ждет пока дерево сначала достроится и потом вызывает ребилд
    Future.microtask(
      () => context.read<MovieDetailsModel>().setUpLocale(context),
    );
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
    final isLoading = context.select(
      (MovieDetailsModel model) => model.data.isLoading,
    );
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        ChangeNotifierProvider(
          create: (_) => MovieDetailsMainInfoWidgetModel(),
          child: MovieDetailsMainInfoWidget(),
        ),
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
    final title = context.select((MovieDetailsModel model) => model.data.title);
    return Text(title, style: TextStyle(color: Colors.white));
  }
}
