import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';
import 'package:moviedb_app_llf/ui/widgets/loader_widget/loader_view_cubit.dart';

class LoaderWidget extends StatefulWidget {
  const LoaderWidget({super.key});

  @override
  State<LoaderWidget> createState() => _LoaderWidgetState();
}

class _LoaderWidgetState extends State<LoaderWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoaderViewCubit, LoaderViewCubitState>(
      listenWhen:
          (previous, current) => current != LoaderViewCubitState.unknown,
      listener: (BuildContext context, LoaderViewCubitState state) {
        _onLoaderViewCubitStateChange(context, state);
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  void _onLoaderViewCubitStateChange(
    BuildContext context,
    LoaderViewCubitState state,
  ) {
    final nextScreen =
        state == LoaderViewCubitState.authorized
            ? MainNavigationRoutesName.mainScreen
            : MainNavigationRoutesName.auth;
    Navigator.of(context).pushReplacementNamed(nextScreen);
  }
}
