import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/domain/api_client/api_client_exception.dart';
import 'package:moviedb_app_llf/domain/services/auth_service.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';

class AuthModel extends ChangeNotifier {
  final _authService = AuthService();

  final loginTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAuthProgress = false;
  bool get canStartAuth => !_isAuthProgress;
  bool get isAuthProgress => _isAuthProgress;

  bool _isValid(String login, String password) =>
      login.isNotEmpty || password.isNotEmpty;

  Future<String?> _login(String login, String password) async {
    try {
      await _authService.login(login, password);
    } on ApiClientException catch (e) {
      switch (e.type) {
        case ApiCLientExceptionType.network:
          return 'Сервер недоступен, нет подключения к инету';

        case ApiCLientExceptionType.auth:
          return 'Неправильный логин или пароль';
        case ApiCLientExceptionType.sessionExpired:
          return 'Произошла ошибка. Срок сессии истек';
        case ApiCLientExceptionType.apiKey:
          return 'Неверный ApiKey';
        case ApiCLientExceptionType.other:
          return 'Произошла ошибка. Попробуйте еще раз';
      }
    } catch (e) {
      return 'Неизвестная ошибка, поторите попытку';
    }
    return null;
  }

  Future<void> auth(BuildContext context) async {
    final login = loginTextController.text;
    final password = passwordTextController.text;

    if (!_isValid(login, password)) {
      _updateState('Заполните логин и пароль', false);
      return;
    }

    _updateState(null, true);

    _errorMessage = await _login(login, password);
    if (_errorMessage == null) {
      MainNavigation.resetNavigatiob(context);
    } else {
      _updateState(_errorMessage, false);
    }
  }

  void _updateState(String? errorMessage, bool isAuthProgress) {
    if (_errorMessage == errorMessage && _isAuthProgress == isAuthProgress) {
      return;
    }
    _errorMessage = errorMessage;
    _isAuthProgress = isAuthProgress;
    notifyListeners();
  }
}
