import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moviedb_app_llf/domain/api_client/api_client_exception.dart';
import 'package:moviedb_app_llf/domain/blocs/auth_bloc.dart';

abstract class AuthViewCubitState {}

class AuthViewCubitFormFillingInProgressState extends AuthViewCubitState {}

class AuthViewCubitErrorState extends AuthViewCubitState {
  final String _errorMessage;
  get errorMessage => _errorMessage;
  AuthViewCubitErrorState(this._errorMessage, bool isAuthProgress);

  @override
  bool operator ==(covariant AuthViewCubitErrorState other) {
    if (identical(this, other)) return true;

    return other._errorMessage == _errorMessage;
  }

  @override
  int get hashCode => _errorMessage.hashCode;
}

class AuthViewCubitInProgressState extends AuthViewCubitState {}

class AuthViewCubitSuccessAuthState extends AuthViewCubitState {}

class AuthViewCubit extends Cubit<AuthViewCubitState> {
  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> authBlocSubscription;

  AuthViewCubit(super.initialState, this.authBloc) {
    _onState(authBloc.state);
    authBlocSubscription = authBloc.stream.listen(_onState);
  }

  bool _isValid(String login, String password) =>
      login.isNotEmpty || password.isNotEmpty;

  void auth({required String login, required String password}) {
    if (!_isValid(login, password)) {
      final state = AuthViewCubitErrorState('Заполните логин и пароль', false);
      emit(state);
      return;
    }
    // emit(AuthViewCubitState(null, true));
    authBloc.add(AuthLoginEvent(login: login, password: password));
  }

  void _onState(AuthState state) {
    if (state is AuthAuthorizedState) {
      authBlocSubscription.cancel();
      emit(AuthViewCubitSuccessAuthState());
    } else if (state is AuthUnAuthorizedState) {
      emit(AuthViewCubitFormFillingInProgressState());
    } else if (state is AuthFailureState) {
      final message = _mapErrorToMessage(state.error);
      emit(AuthViewCubitErrorState(message, false));
    } else if (state is AuthInProgressState) {
      emit(AuthViewCubitInProgressState());
    } else if (state is AuthCheckStatusInProgressState) {
      emit(AuthViewCubitInProgressState());
    }
  }

  String _mapErrorToMessage(Object error) {
    if (error is! ApiClientException) {
      return 'Неизвестная ошибка, поторите попытку';
    }
    switch (error.type) {
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
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    return super.close();
  }
}

// class AuthModel extends ChangeNotifier {
//   final _authService = AuthService();

//   final loginTextController = TextEditingController();
//   final passwordTextController = TextEditingController();

//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;

//   bool _isAuthProgress = false;
//   bool get canStartAuth => !_isAuthProgress;
//   bool get isAuthProgress => _isAuthProgress;

//   bool _isValid(String login, String password) =>
//       login.isNotEmpty || password.isNotEmpty;

//   Future<String?> _login(String login, String password) async {
//     try {
//       await _authService.login(login, password);
//     } on ApiClientException catch (e) {
//       switch (e.type) {
//         case ApiCLientExceptionType.network:
//           return 'Сервер недоступен, нет подключения к инету';

//         case ApiCLientExceptionType.auth:
//           return 'Неправильный логин или пароль';
//         case ApiCLientExceptionType.sessionExpired:
//           return 'Произошла ошибка. Срок сессии истек';
//         case ApiCLientExceptionType.apiKey:
//           return 'Неверный ApiKey';
//         case ApiCLientExceptionType.other:
//           return 'Произошла ошибка. Попробуйте еще раз';
//       }
//     } catch (e) {
//       return 'Неизвестная ошибка, поторите попытку';
//     }
//     return null;
//   }

//   Future<void> auth(BuildContext context) async {
//     final login = loginTextController.text;
//     final password = passwordTextController.text;

//     if (!_isValid(login, password)) {
//       _updateState('Заполните логин и пароль', false);
//       return;
//     }

//     _updateState(null, true);

//     _errorMessage = await _login(login, password);
//     if (_errorMessage == null) {
//       MainNavigation.resetNavigation(context);
//     } else {
//       _updateState(_errorMessage, false);
//     }
//   }

//   void _updateState(String? errorMessage, bool isAuthProgress) {
//     if (_errorMessage == errorMessage && _isAuthProgress == isAuthProgress) {
//       return;
//     }
//     _errorMessage = errorMessage;
//     _isAuthProgress = isAuthProgress;
//     notifyListeners();
//   }
// }
