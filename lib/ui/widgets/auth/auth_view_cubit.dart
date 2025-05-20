import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moviedb_app_llf/domain/api_client/api_client_exception.dart';
import 'package:moviedb_app_llf/domain/blocs/auth_bloc.dart';

abstract class AuthViewCubitState {}

class AuthViewCubitFillingInProgressState extends AuthViewCubitState {}

class AuthViewCubitErrorState extends AuthViewCubitState {
  final String _errorMessage;
  get errorMessage => _errorMessage;
  AuthViewCubitErrorState(this._errorMessage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthViewCubitErrorState &&
          runtimeType == other.runtimeType &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => errorMessage.hashCode;
}

class AuthViewCubitInProgressState extends AuthViewCubitState {}

class AuthViewCubitSuccessAuthState extends AuthViewCubitState {}

class AuthViewCubit extends Cubit<AuthViewCubitState> {
  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> authBlocSubscription;

  AuthViewCubit(super.initialState, this.authBloc) {
    print('AuthViewCubit received state: ${state.runtimeType}');
    print('AuthViewCubit received state: ${authBloc.state}');
    _onState(authBloc.state);
    authBlocSubscription = authBloc.stream.listen(_onState);
  }

  bool _isValid(String login, String password) =>
      login.isNotEmpty && password.isNotEmpty;

  void auth({required String login, required String password}) {
    if (!_isValid(login, password)) {
      final state = AuthViewCubitErrorState('Заполните логин и пароль');
      emit(state);
      return;
    }
    // emit(AuthViewCubitState(null, true));
    authBloc.add(AuthLoginEvent(login: login, password: password));
  }

  void _onState(AuthState state) {
    print('AuthViewCubit received state: ${state.runtimeType}');
    if (state is AuthAuthorizedState) {
      authBlocSubscription.cancel();
      emit(AuthViewCubitSuccessAuthState());
    } else if (state is AuthUnAuthorizedState) {
      emit(AuthViewCubitFillingInProgressState());
    } else if (state is AuthFailureState) {
      final message = _mapErrorToMessage(state.error);
      emit(AuthViewCubitErrorState(message));
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
