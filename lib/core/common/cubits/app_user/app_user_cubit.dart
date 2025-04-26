import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/sf_handler.dart';
import '../../entities/user.dart';
import '../app_socket/app_socket_cubit.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  final SFHandler _sfHandler;
  final AppSocketCubit _appSocketCubit;

  AppUserCubit({
    required SFHandler sfHandler,
    required AppSocketCubit appSocketCubit,
  })  : _sfHandler = sfHandler,
        _appSocketCubit = appSocketCubit,
        super(AppUserInitial());

  void setUser(User user) {
    emit(AppUserLoggedin(user: user));
  }

  void removeUser() {
    emit(AppUserInitial());
  }

  User? get user {
    if (state is AppUserLoggedin) {
      return (state as AppUserLoggedin).user;
    }
    return null;
  }

  Future<void> logoutUser(BuildContext context) async {
    _appSocketCubit.disconnectSocket();

    await _sfHandler.deleteId();
    await _sfHandler.deleteToken();
    await _sfHandler.deleteExpiresIn();

    removeUser();

    if (context.mounted) {
      context.go('/login');
    }
  }
}
