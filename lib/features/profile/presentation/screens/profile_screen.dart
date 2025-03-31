import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/common/cubits/app_theme/theme_cubit.dart';
import '../../../../core/common/cubits/app_theme/theme_state.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/utils/sf_handler.dart';
import '../../../../init_dependencies.dart';

import '../widgets/verification_pill.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 3) {
      return phoneNumber;
    }

    if (phoneNumber.startsWith('+91') && phoneNumber.length > 3) {
      return '${phoneNumber.substring(0, 3)} ${phoneNumber.substring(3, 8)} ${phoneNumber.substring(8)}';
    }

    final buffer = StringBuffer();
    for (int i = 0; i < phoneNumber.length; i++) {
      buffer.write(phoneNumber[i]);
      if ((i + 1) % 5 == 0 && i != phoneNumber.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  Future<void> _logoutUser(BuildContext context) async {
    final sfHandler = serviceLocator<SFHandler>();
    final appUserCubit = context.read<AppUserCubit>();

    await sfHandler.deleteId();
    await sfHandler.deleteToken();
    await sfHandler.deleteExpiresIn();

    appUserCubit.removeUser();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AppUserCubit, AppUserState>(
        builder: (context, state) {
          if (state is AppUserLoggedin) {
            return CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(state.user.name),
                    background: Container(
                      color: Theme.of(context).primaryColor.withValues(
                            alpha: 0.1,
                          ),
                      child: Center(
                        child: Hero(
                          tag: 'profile_avatar',
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.amber,
                            child: Center(
                              child: Text(
                                state.user.name[0].toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // User Info Card
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Member Since'),
                            subtitle: Text(
                              DateFormat.yMMMd().format(
                                DateTime.parse(state.user.createdAt!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Contact Info Card
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.contact_mail),
                                title: const Text('Contact Information'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {},
                                ),
                              ),
                              const Divider(),
                              // Email Section
                              ListTile(
                                leading: const Icon(Icons.email_outlined),
                                title: state.user.email != null
                                    ? Text(state.user.email!)
                                    : TextButton(
                                        onPressed: () {},
                                        child: const Text('Add Email'),
                                      ),
                                trailing: state.user.email != null
                                    ? VerificationPill(
                                        isVerified: state.user.isEmailVerified,
                                        verificationType: 'email',
                                      )
                                    : null,
                              ),
                              // Phone Section
                              ListTile(
                                leading: const Icon(Icons.phone_outlined),
                                title: state.user.phone != null
                                    ? Text(
                                        _formatPhoneNumber(state.user.phone!),
                                      )
                                    : TextButton(
                                        onPressed: () {},
                                        child: const Text('Add Phone'),
                                      ),
                                trailing: state.user.phone != null
                                    ? VerificationPill(
                                        isVerified: state.user.isPhoneVerified,
                                        verificationType: 'phone',
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Listings Card
                        const Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.home_outlined),
                                title: Text('My Listings'),
                                trailing: Text('2 Active'),
                              ),
                              Divider(),
                              ListTile(
                                title: Text('Total Listings'),
                                trailing: Text('5'),
                              ),
                              ListTile(
                                title: Text('Active Listings'),
                                trailing: Text('2'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reviews Card
                        const Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.star_outline),
                                title: Text('Reviews'),
                                trailing: Text('4.5★'),
                              ),
                              Divider(),
                              ListTile(
                                title: Text('Total Reviews'),
                                trailing: Text('12'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Column(
                            children: <Widget>[
                              const ListTile(
                                leading: Icon(
                                  Icons.account_circle_outlined,
                                  color: Colors.grey,
                                ),
                                title: Text('Account Actions'),
                              ),
                              const Divider(),
                              BlocBuilder<ThemeCubit, ThemeState>(
                                builder: (context, state) {
                                  return ListTile(
                                    leading: Icon(
                                      state.isDarkMode
                                          ? Icons.dark_mode_outlined
                                          : Icons.light_mode_outlined,
                                      color: Colors.grey,
                                    ),
                                    title: const Text('Theme'),
                                    trailing: Switch(
                                      value: state.isDarkMode,
                                      onChanged: (_) => context
                                          .read<ThemeCubit>()
                                          .toggleTheme(),
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.help_outline,
                                  color: Colors.grey,
                                ),
                                title: const Text('Help & Support'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // Handle help tap
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.logout,
                                  color: Colors.redAccent,
                                ),
                                title: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Logout'),
                                      content: const Text(
                                          'Are you sure you want to logout?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            context.pop();
                                            _logoutUser(context);
                                          },
                                          child: const Text(
                                            'Logout',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
