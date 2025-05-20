// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviedb_app_llf/domain/api_client/account_api_client.dart';
import 'package:moviedb_app_llf/domain/api_client/auth_api_client.dart';
import 'package:moviedb_app_llf/domain/data_providers/session_data_provider.dart';

abstract class AuthEvents {}

class AuthCheckStatusEvent extends AuthEvents {}

class AuthLogoutEvent extends AuthEvents {}

class AuthLoginEvent extends AuthEvents {
  final String login;
  final String password;

  AuthLoginEvent({required this.login, required this.password});
}

abstract class AuthState {}

class AuthUnAuthorizedState extends AuthState {}

class AuthAuthorizedState extends AuthState {}

class AuthFailureState extends AuthState {
  final Object error;

  AuthFailureState({required this.error});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailureState &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}

class AuthInProgressState extends AuthState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthInProgressState && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class AuthCheckStatusInProgressState extends AuthState {}

class AuthBloc extends Bloc<AuthEvents, AuthState> {
  final _authApiClient = AuthApiClient();
  final _accountApiClient = AccountApiClient();
  final _sessionDataProvider = SessionDataProvider();
  AuthBloc(super.initialState) {
    // обработка ивентов
    on<AuthEvents>((event, emit) async {
      if (event is AuthCheckStatusEvent) {
        await onAuthCheckStatusEvent(event, emit);
      } else if (event is AuthLoginEvent) {
        await onAuthLoginEvent(event, emit);
      } else if (event is AuthLogoutEvent) {
        await onAuthLogoutEvent(event, emit);
      }
    }, transformer: sequential());
    // закидывает ивент проверки авторизации
    add(AuthCheckStatusEvent());
  }

  // проверка на авторизованность
  Future<void> onAuthCheckStatusEvent(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInProgressState());
    final sessionId = await _sessionDataProvider.getSessionId();
    final newState =
        sessionId != null ? AuthAuthorizedState() : AuthUnAuthorizedState();
    emit(newState); // выдает новый стейт
  }

  Future<void> onAuthLoginEvent(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthInProgressState());
      final sessionId = await _authApiClient.auth(
        username: event.login,
        password: event.password,
      );
      final accountId = await _accountApiClient.getAccountId(sessionId);
      await _sessionDataProvider.setSessionId(sessionId);
      await _sessionDataProvider.setAccountId(accountId);
      emit(AuthAuthorizedState());
    } catch (e) {
      emit(AuthFailureState(error: e));
    }
  }

  Future<void> onAuthLogoutEvent(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _sessionDataProvider.deleteAccountId();
    await _sessionDataProvider.deleteSessionId();
    emit(AuthUnAuthorizedState());
  }
}
