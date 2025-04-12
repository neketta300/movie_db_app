import 'package:moviedb_app_llf/library/widgets/inherited/provider.dart';
import 'package:moviedb_app_llf/ui/widgets/app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/ui/widgets/app/my_app_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final model = MyAppModel();
  await model.checkAuth();
  const app = MyApp();
  final widget = Provider(model: model, child: app);
  runApp(widget);
}
