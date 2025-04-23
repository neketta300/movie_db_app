import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/domain/services/auth_service.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

class LoaderViewModel {
  final BuildContext context;
  final _authService = AuthService();

  LoaderViewModel(this.context) {
    asyncInitCheck();
  }

  Future<void> asyncInitCheck() async {
    await checkAuth();
  }

  Future<void> checkAuth() async {
    final isAuth = await _authService.isAuth();
    final nextScreen =
        isAuth
            ? MainNavigationRoutesName.mainScreen
            : MainNavigationRoutesName.auth;
    Navigator.of(context).pushReplacementNamed(nextScreen);
  }
}
