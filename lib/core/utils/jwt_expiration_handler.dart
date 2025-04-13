import 'dart:async';

import 'package:flutter/material.dart';

import '../common/cubits/app_user/app_user_cubit.dart';
import './sf_handler.dart';

class JwtExpirationHandler {
  final SFHandler _sfHandler;
  final AppUserCubit _appUserCubit;
  Timer? _expiryTimer;

  JwtExpirationHandler(
      {required SFHandler sfHandler, required AppUserCubit appUserCubit})
      : _sfHandler = sfHandler,
        _appUserCubit = appUserCubit;

  void startExpiryCheck(BuildContext context) {
    _expiryTimer?.cancel();

    final expiresInString = _sfHandler.getExpiresIn();
    if (expiresInString == null) {
      return;
    }

    try {
      final expiryDate = DateTime.parse(expiresInString);
      final currentDate = DateTime.now();

      if (currentDate.isAfter(expiryDate)) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(content: Text('Please login again')));

        stopExpiryCheck();
        _appUserCubit.logoutUser(context);
        return;
      }

      final timeUntilExpiry = expiryDate.difference(currentDate);

      _expiryTimer = Timer(timeUntilExpiry, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(const SnackBar(content: Text('Please login again')));

          stopExpiryCheck();
          _appUserCubit.logoutUser(context);
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Invalid token expiration date. Please login again'),
          ),
        );

      stopExpiryCheck();
      _appUserCubit.logoutUser(context);
    }
  }

  void stopExpiryCheck() {
    _expiryTimer?.cancel();
    _expiryTimer = null;
  }
}
