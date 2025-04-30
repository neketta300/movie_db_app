import 'package:moviedb_app_llf/domain/api_client/image_downloader.dart';
import 'package:moviedb_app_llf/ui/widgets/elements/radial_percent_widget.dart';
import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_main_info_widget_model.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_model.dart';
import 'package:provider/provider.dart';

class MovieDetailsMainInfoWidget extends StatelessWidget {
  const MovieDetailsMainInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TopPosterWidget(),
        const Padding(padding: EdgeInsets.all(20.0), child: _MovieNameWidget()),
        const _ScoreWidget(),
        const _SummaryWidget(),
        Padding(padding: const EdgeInsets.all(10.0), child: _overviewWidget()),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: _DescriptionWidget(),
        ),
        const SizedBox(height: 30),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: _PeopleWidgets(),
        ),
      ],
    );
  }

  Text _overviewWidget() {
    return const Text(
      'Описание',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget();

  @override
  Widget build(BuildContext context) {
    final overview = context.select((MovieDetailsModel m) => m.data.overview);
    return Text(
      overview,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _TopPosterWidget extends StatelessWidget {
  const _TopPosterWidget();

  @override
  Widget build(BuildContext context) {
    // просто получил модель
    final model = context.read<MovieDetailsModel>();
    // получая обновления только movieDetails
    final posterData = context.select(
      (MovieDetailsModel model) => model.data.posterData,
    );

    final backdropPath = posterData.backdropPath;
    final posterPath = posterData.posterPath;
    final favoriteIcon = posterData.favoriteIcon;

    return AspectRatio(
      aspectRatio: 411 / 231,
      child: Stack(
        children: [
          if (backdropPath != null)
            Image.network(ImageDownloader.imageUrl(backdropPath)),
          if (posterPath != null)
            Positioned(
              top: 20,
              left: 20,
              bottom: 20,
              child: Image.network(ImageDownloader.imageUrl(posterPath)),
            ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              onPressed: () => model.toggleFavorite(context),
              icon: Icon(favoriteIcon),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieNameWidget extends StatelessWidget {
  const _MovieNameWidget();

  @override
  Widget build(BuildContext context) {
    final nameData = context.select((MovieDetailsModel m) => m.data.nameData);

    return Center(
      child: RichText(
        maxLines: 3,
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: nameData.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: nameData.year,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  const _ScoreWidget();

  @override
  Widget build(BuildContext context) {
    final model = context.read<MovieDetailsMainInfoWidgetModel>();
    final scoreData = context.select((MovieDetailsModel m) => m.data.scoreData);
    final trailerKey = scoreData.trailerKey;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () {},
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: RadialPercentWidget(
                  percent: scoreData.voteAverage / 100,
                  fillColor: const Color.fromARGB(255, 10, 23, 25),
                  lineColor: const Color.fromARGB(255, 37, 203, 103),
                  freeColor: const Color.fromARGB(255, 25, 54, 31),
                  lineWidth: 3,
                  child: Text(
                    scoreData.voteAverage.toStringAsFixed(0),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text('User Score', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        Container(width: 1, height: 15, color: Colors.grey),
        if (trailerKey != null)
          TextButton(
            onPressed: () => model.onPlayTrailerTap(context, trailerKey),
            child: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white30),
                SizedBox(width: 3),
                const Text(
                  'Play Trailer',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SummaryWidget extends StatelessWidget {
  const _SummaryWidget();

  @override
  Widget build(BuildContext context) {
    final summary = context.select((MovieDetailsModel m) => m.data.summary);
    return ColoredBox(
      color: const Color.fromRGBO(22, 21, 25, 1.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Text(
          summary,
          maxLines: 3,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _PeopleWidgets extends StatelessWidget {
  const _PeopleWidgets();

  @override
  Widget build(BuildContext context) {
    var crew = context.select((MovieDetailsModel m) => m.data.peopleData);

    return Column(
      children:
          crew
              .map(
                (chunk) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PeopleWidgetRow(employes: chunk),
                ),
              )
              .toList(),
    );
  }
}

class _PeopleWidgetRow extends StatelessWidget {
  final List<MovieDetailsPeopleData> employes;
  const _PeopleWidgetRow({required this.employes});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children:
          employes
              .map((employee) => _PeopleWidgetRowItem(employee: employee))
              .toList(),
    );
  }
}

class _PeopleWidgetRowItem extends StatelessWidget {
  final MovieDetailsPeopleData employee;
  const _PeopleWidgetRowItem({required this.employee});

  @override
  Widget build(BuildContext context) {
    const nameStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
    const jobTilteStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(employee.name, style: nameStyle),
          Text(employee.job, style: jobTilteStyle),
        ],
      ),
    );
  }
}
