import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/domain/data_providers/session_data_provider.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

class MyAppModel {
  final _sessionDataProvider = SessionDataProvider();
  var _isAuth = false;
  bool get isAuth => _isAuth;

  Future<void> checkAuth() async {
    final sessionId = await _sessionDataProvider.getSessionId();
    _isAuth = sessionId != null;
  }

  Future<void> resetSession(BuildContext context) async {
    await _sessionDataProvider.setAccountId(null);
    await _sessionDataProvider.setSessionId(null);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(MainNavigationRoutesName.auth, (route) => false);
  }
}
