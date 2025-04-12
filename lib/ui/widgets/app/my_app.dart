import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:moviedb_app_llf/library/widgets/inherited/provider.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';
import 'package:moviedb_app_llf/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/ui/widgets/app/my_app_model.dart';

class MyApp extends StatelessWidget {
  // final MyAppModel model;
  static final mainNavigation = MainNavigation();
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.read<MyAppModel>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.mainDarkBlue),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.mainDarkBlue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ru', 'RU'), // English
        Locale('en'), // Russian
      ],
      routes: mainNavigation.routes,
      initialRoute: mainNavigation.initialRoute(model?.isAuth == true),
      onGenerateRoute: mainNavigation.onGenerateRoute,
    );
  }
}
