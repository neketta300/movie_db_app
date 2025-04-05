import 'package:moviedb_app_llf/domain/api_client/api_client.dart';
import 'package:moviedb_app_llf/library/widgets/inherited/provider.dart';
import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_details/movie_details_model.dart';

class MovieDetailsMainScreenCastWidget extends StatelessWidget {
  const MovieDetailsMainScreenCastWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Актерский состав',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            height: 250,
            child: Scrollbar(child: const _ActorListWidget()),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextButton(
              onPressed: () {},
              child: const Text('Full Cast & Crew'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActorListWidget extends StatelessWidget {
  const _ActorListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    var crew = model?.movieDetails?.credits.crew;
    if (crew == null || crew.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      itemCount: 20,
      itemExtent: 120,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return _ActorListItemWidget(actorIndex: index);
      },
    );
  }
}

class _ActorListItemWidget extends StatelessWidget {
  final int actorIndex;
  const _ActorListItemWidget({super.key, required this.actorIndex});

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.read<MovieDetailsModel>(context);
    final actor = model!.movieDetails!.credits.cast![actorIndex];
    final actorProfilePath = actor.profilePath;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              actorProfilePath != null
                  ? Image.network(ApiClient.imageUrl(actorProfilePath))
                  : const SizedBox.shrink(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(actor.name, maxLines: 1),
                      const SizedBox(height: 7),
                      Text(actor.character, maxLines: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
