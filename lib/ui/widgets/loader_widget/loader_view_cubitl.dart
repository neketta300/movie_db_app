import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moviedb_app_llf/domain/blocs/auth_bloc.dart';

enum LoaderViewCubitState { unknown, authorized, notAuthorized }

class LoaderViewCubit extends Cubit<LoaderViewCubitState> {
  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> authBlocSubscription;

  LoaderViewCubit(super.initialState, this.authBloc) {
    Future.microtask(() {
      _onState(authBloc.state);
      authBlocSubscription = authBloc.stream.listen(_onState);
      authBloc.add(AuthCheckStatusEvent());
    });
  }

  void _onState(AuthState state) {
    if (state is AuthAuthorizedState) {
      emit(LoaderViewCubitState.authorized);
    } else if (state is AuthUnAuthorizedState) {
      emit(LoaderViewCubitState.notAuthorized);
    }
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    return super.close();
  }
}

// class LoaderViewModel {
//   final BuildContext context;
//   final _authService = AuthService();

//   LoaderViewModel(this.context) {
//     asyncInitCheck();
//   }

//   Future<void> asyncInitCheck() async {
//     await checkAuth();
//   }

//   Future<void> checkAuth() async {
//     final isAuth = await _authService.isAuth();
//     final nextScreen =
//         isAuth
//             ? MainNavigationRoutesName.mainScreen
//             : MainNavigationRoutesName.auth;
//     Navigator.of(context).pushReplacementNamed(nextScreen);
//   }
// }
