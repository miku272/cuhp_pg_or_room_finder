import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/utils/jwt_expiration_handler.dart';
import '../../../../core/utils/sf_handler.dart';

import '../../../../init_dependencies.dart';
import '../bloc/splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late JwtExpirationHandler _jwtExpirationHandler;

  @override
  void initState() {
    super.initState();
    _jwtExpirationHandler = serviceLocator<JwtExpirationHandler>();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final SFHandler sfHandler = serviceLocator();

    final id = sfHandler.getId();
    final token = sfHandler.getToken();

    context.read<SplashBloc>().add(SplashGetCurrentUser(id: id, token: token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashFailure) {
            log('Error in splash screen: ', error: state.message);
            context.pushReplacement('/login');
          }

          if (state is SplashSuccess) {
            if (state.user == null) {
              context.pushReplacement('/login');
            } else {
              _jwtExpirationHandler.startExpiryCheck(context);

              context.pushReplacement('/');
            }
          }
        },
        child: Center(
          child: Lottie.asset(
            'assets/loader/home_button.json',
            width: 150,
            height: 150,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
