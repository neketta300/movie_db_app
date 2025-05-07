import 'package:moviedb_app_llf/ui/widgets/news/news_model.dart';
import 'package:moviedb_app_llf/ui/widgets/news/news_widget_free_to_watch.dart';
import 'package:moviedb_app_llf/ui/widgets/news/news_widget_leaderboards.dart';
import 'package:moviedb_app_llf/ui/widgets/news/news_widget_popular.dart';
import 'package:moviedb_app_llf/ui/widgets/news/news_widget_trailers.dart';
import 'package:moviedb_app_llf/ui/widgets/news/news_widget_trandings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsWidget extends StatefulWidget {
  const NewsWidget({super.key});

  @override
  State<NewsWidget> createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  @override
  void didChangeDependencies() {
    final locale = Localizations.localeOf(context);
    context.read<NewsViewModel>().setupLocale(locale);
    super.didChangeDependencies();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        NewsWidgetPopular(),
        NewsWidgetFreeToWatch(),
        NewsWidgetTrailers(),
        NewsWidgetTrandings(),
        NewsWidgetLeaderboards(),
      ],
    );
  }
}
