import 'package:moviedb_app_llf/domain/data_providers/session_data_provider.dart';
import 'package:moviedb_app_llf/library/widgets/inherited/provider.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_list/movie_list_model.dart';
import 'package:moviedb_app_llf/ui/widgets/movie_list/movie_list_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/news/news_widget.dart';
import 'package:moviedb_app_llf/ui/widgets/tv_show_list/tv_show_list_widget.dart';
import 'package:flutter/material.dart';

class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({super.key});

  @override
  _MainScreenWidgetState createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {
  int _selectedTab = 0;
  final movieListModel = MovieListModel();

  void onSelectTab(int index) {
    if (_selectedTab == index) return;
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    movieListModel.setupLocale(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('TMDB', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => SessionDataProvider().setSessionId(null),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          const NewsWidget(),
          NotifierProvider(
            create: () => movieListModel,
            isManagingModel: false,
            child: MovieListWidget(),
          ),
          TWShowListWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Новости',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter),
            label: 'Фильмы',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Сериалы'),
        ],
        onTap: onSelectTab,
      ),
    );
  }
}
