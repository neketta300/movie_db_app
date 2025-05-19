import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moviedb_app_llf/ui/navigation/main_navigation.dart';
import 'package:moviedb_app_llf/ui/theme/app_button_style.dart';
import 'package:moviedb_app_llf/ui/widgets/auth/auth_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:moviedb_app_llf/ui/widgets/loader_widget/loader_view_cubitl.dart';
import 'package:provider/provider.dart';

class _AuthDataStorage {
  String login = '';
  String password = '';
}

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthViewCubit, AuthViewCubitState>(
      listenWhen: (_, current) => current is AuthViewCubitSuccessAuthState,
      listener: _onAuthViewCubitStateChange,
      child: Provider(
        create: (_) => _AuthDataStorage(),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Login to your account',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: ListView(children: [const _HeaderWidget()]),
        ),
      ),
    );
  }

  void _onAuthViewCubitStateChange(
    BuildContext context,
    AuthViewCubitState state,
  ) {
    if (state is AuthViewCubitSuccessAuthState) {
      MainNavigation.resetNavigation(context);
    }
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 16, color: Colors.black);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          const _FormWidget(),
          const SizedBox(height: 25),
          const Text(
            'In order to use the editing and rating capabilities of TMDb, as well as get personal recommendations you will need to login to your account. If you do not have an account, registering for an account is free and simple.',
            style: textStyle,
          ),
          const SizedBox(height: 5),
          TextButton(
            style: AppButtonStyle.linkButton,
            onPressed: () {},
            child: const Text('Register'),
          ),
          const SizedBox(height: 25),
          const Text(
            'If you signed up but didn`t get your verification email.',
            style: textStyle,
          ),
          const SizedBox(height: 5),
          TextButton(
            style: AppButtonStyle.linkButton,
            onPressed: () {},
            child: const Text('Verify email'),
          ),
        ],
      ),
    );
  }
}

class _FormWidget extends StatelessWidget {
  const _FormWidget();

  @override
  Widget build(BuildContext context) {
    final authDataStorage =
        context
            .read<
              _AuthDataStorage
            >(); //NotifierProvider.read<AuthModel>(context);
    const textStyle = TextStyle(fontSize: 16, color: Color(0xFF212529));
    const textFieldDecorator = InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      isCollapsed: true,
      fillColor: Colors.red,
      focusColor: Colors.red,
      hoverColor: Colors.red,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ErrorMessageWidget(),
        const Text('Username', style: textStyle),
        const SizedBox(height: 5),
        TextField(
          decoration: textFieldDecorator,
          onChanged: (text) => authDataStorage.login = text,
        ),
        const SizedBox(height: 20),
        const Text('Password', style: textStyle),
        const SizedBox(height: 5),
        TextField(
          decoration: textFieldDecorator,
          onChanged: (text) => authDataStorage.password = text,
          obscureText: true,
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            const _AuthButtonWidget(),
            const SizedBox(width: 30),
            TextButton(
              onPressed: () {},
              style: AppButtonStyle.linkButton,
              child: const Text('Reset password'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthButtonWidget extends StatelessWidget {
  const _AuthButtonWidget();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AuthViewCubit>();
    const color = Color(0xFF01B4E4);
    final canStartAuth =
        cubit.state is AuthViewCubitFormFillingInProgressState ||
        cubit.state is AuthViewCubitErrorState;
    final authDataStorage = context.read<_AuthDataStorage>();
    final onPressed =
        canStartAuth
            ? () => cubit.auth(
              login: authDataStorage.login,
              password: authDataStorage.password,
            )
            : null;
    final child =
        cubit.state is AuthViewCubitInProgressState
            ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
            : const Text('Login');
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
      ),
      child: child,
    );
  }
}

class _ErrorMessageWidget extends StatelessWidget {
  const _ErrorMessageWidget();

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.select((AuthViewCubit a) {
      final state = a.state;
      return state is AuthViewCubitErrorState ? state.errorMessage : null;
    });
    if (errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        errorMessage,
        style: const TextStyle(fontSize: 17, color: Colors.red),
      ),
    );
  }
}
