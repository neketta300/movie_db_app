import 'package:moviedb_app_llf/domain/api_client/image_downloader.dart';
import 'package:moviedb_app_llf/ui/widgets/elements/radial_percent_widget.dart';
import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/ui/widgets/news/news_model.dart';
import 'package:provider/provider.dart';

class NewsWidgetFreeToWatch extends StatefulWidget {
  const NewsWidgetFreeToWatch({super.key});

  @override
  State<NewsWidgetFreeToWatch> createState() => _NewsWidgetFreeToWatchState();
}

class _NewsWidgetFreeToWatchState extends State<NewsWidgetFreeToWatch> {
  @override
  void didChangeDependencies() {
    final locale = Localizations.localeOf(context);
    context.read<NewsViewModel>().setupLocale(locale);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NewsViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WhatsPopularRowWidget(),
        const SizedBox(height: 20),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: model.freeMovies.length,
            itemExtent: 150,
            itemBuilder: (BuildContext context, int index) {
              model.showedMovieAtIndex(index, MovieListType.free);
              return _MoviesListDataWidget(index: index);
            },
          ),
        ),
      ],
    );
  }
}

class _MoviesListDataWidget extends StatelessWidget {
  const _MoviesListDataWidget({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    final model = context.read<NewsViewModel>();
    final movie = model.freeMovies[index];
    final posterPath = movie.filmData.posterPath;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => model.onMovieTap(context, index, MovieListType.free),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          posterPath != null
                              ? Image.network(
                                ImageDownloader.imageUrl(posterPath),
                                width: 150,
                              )
                              : SizedBox.shrink(),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.more_horiz),
                    ),
                  ),
                  _ScoreWidget(index: index),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                child: Text(
                  movie.filmData.title,
                  maxLines: 2,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                child: Text(movie.filmData.releaseDate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  const _ScoreWidget({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final score = context.select(
      (NewsViewModel m) => m.freeMovies[index].filmData.voteAverage,
    );
    return Positioned(
      left: 10,
      bottom: 0,
      child: SizedBox(
        width: 40,
        height: 40,
        child: RadialPercentWidget(
          percent: score / 100,
          fillColor: const Color.fromARGB(255, 10, 23, 25),
          lineColor: const Color.fromARGB(255, 37, 203, 103),
          freeColor: const Color.fromARGB(255, 25, 54, 31),
          lineWidth: 3,
          child: Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
    );
  }
}

class _WhatsPopularRowWidget extends StatelessWidget {
  const _WhatsPopularRowWidget();

  @override
  Widget build(BuildContext context) {
    final category = 'movies';
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Бесплатны к просмотру',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          DropdownButton<String>(
            value: category,
            onChanged: (catrgory) {},
            items: [
              const DropdownMenuItem(value: 'movies', child: Text('Фильмы')),
              // const DropdownMenuItem(value: 'tv', child: Text('Передачи')),
              const DropdownMenuItem(value: 'tvShows', child: Text('Сериалы')),
            ],
          ),
        ],
      ),
    );
  }
}
