import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/jwt_expiration_handler.dart';
import '../../../../init_dependencies.dart';

import '../../../../core/common/cubits/app_theme/theme_cubit.dart';
import '../../../../core/common/cubits/app_theme/theme_state.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';

import '../bloc/profile_bloc.dart';

import '../widgets/verification_pill.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AppUserCubit>().user?.jwtToken;
      if (token == null) {
        return;
      }

      context.read<ProfileBloc>().add(
            ProfileGetTotalPropertiesCount(token: token),
          );
      context.read<ProfileBloc>().add(
            ProfileGetPropertiesActiveAndInactiveCount(token: token),
          );

      context.read<ProfileBloc>().add(
            ProfileGetUserReviewsMetadata(token: token),
          );
    });
  }

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

  Future<void> _refreshUser(BuildContext context, String token) async {
    await Future.delayed(const Duration(microseconds: 1));

    if (context.mounted) {
      context.read<ProfileBloc>().add(ProfileGetCurrentUser(token: token));
      context.read<ProfileBloc>().add(
            ProfileGetTotalPropertiesCount(token: token),
          );
      context.read<ProfileBloc>().add(
            ProfileGetPropertiesActiveAndInactiveCount(token: token),
          );
      context.read<ProfileBloc>().add(
            ProfileGetUserReviewsMetadata(token: token),
          );
    }
  }

  Future<void> _logoutUser(BuildContext context) async {
    await context.read<AppUserCubit>().logoutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoading) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text('Updating profile...'),
                  ],
                ),
                duration: Duration(seconds: 2),
              ),
            );
        } else if (state is ProfileFailure) {
          if (state.status == 401) {
            serviceLocator<JwtExpirationHandler>().stopExpiryCheck();
            context.read<AppUserCubit>().logoutUser(context);
          }

          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text('Failed to update: ${state.message}'),
                backgroundColor: Colors.redAccent,
              ),
            );
        } else if (state is ProfileSuccess) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
        }
      },
      child: Scaffold(
        body: BlocBuilder<AppUserCubit, AppUserState>(
          builder: (context, state) {
            if (state is AppUserLoggedin) {
              return RefreshIndicator(
                onRefresh: () async {
                  final token = state.user.jwtToken;

                  await _refreshUser(context, token);
                },
                child: CustomScrollView(
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
                                            isVerified:
                                                state.user.isEmailVerified,
                                            verificationType: 'email',
                                          )
                                        : null,
                                  ),
                                  // Phone Section
                                  ListTile(
                                    leading: const Icon(Icons.phone_outlined),
                                    title: state.user.phone != null
                                        ? Text(
                                            _formatPhoneNumber(
                                                state.user.phone!),
                                          )
                                        : TextButton(
                                            onPressed: () {},
                                            child: const Text('Add Phone'),
                                          ),
                                    trailing: state.user.phone != null
                                        ? VerificationPill(
                                            isVerified:
                                                state.user.isPhoneVerified,
                                            verificationType: 'phone',
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Listings Card
                            BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (context, profileState) {
                                int? totalCount = profileState.totalCount;
                                int? activeCount = profileState.activeCount;
                                int? inactiveCount = profileState.inactiveCount;

                                final bool isLoadingMetadata =
                                    profileState is PropertyMetadataLoading;

                                final bool didMetadataFail =
                                    profileState is PropertyMetadataFailure;

                                return Card(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading:
                                            const Icon(Icons.home_outlined),
                                        title: const Text('My Listings'),
                                        trailing: isLoadingMetadata &&
                                                activeCount == null
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : Text(
                                                '${activeCount ?? (didMetadataFail ? 'Error' : '-')} Active',
                                              ),
                                      ),
                                      const Divider(),
                                      ListTile(
                                        title: const Text('Total Listings'),
                                        trailing: isLoadingMetadata &&
                                                totalCount == null
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : Text(
                                                '${totalCount ?? (didMetadataFail ? 'Error' : '-')}',
                                              ),
                                      ),
                                      ListTile(
                                        title: const Text('Active Listings'),
                                        trailing: isLoadingMetadata &&
                                                activeCount == null
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : Text(
                                                '${activeCount ?? (didMetadataFail ? 'Error' : '-')}',
                                              ),
                                      ),
                                      ListTile(
                                        title: const Text('Inactive Listings'),
                                        trailing: isLoadingMetadata &&
                                                inactiveCount == null
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : Text(
                                                '${inactiveCount ?? (didMetadataFail ? 'Error' : '-')}',
                                              ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Reviews Card
                            BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (context, state) {
                                return Card(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.star_outline),
                                        title: const Text('Reviews'),
                                        trailing: state
                                                is UserReviewMetadataLoading
                                            ? const CircularProgressIndicator(
                                                strokeWidth: 2,
                                              )
                                            : Text(
                                                state.overallAverageRating ==
                                                        null
                                                    ? '-'
                                                    : '${state.overallAverageRating}★',
                                              ),
                                      ),
                                      const Divider(),
                                      ListTile(
                                        title: const Text('Total Reviews'),
                                        trailing: Text(
                                          state.totalReviews == null
                                              ? '-'
                                              : '${state.totalReviews}',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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

                                                serviceLocator<
                                                        JwtExpirationHandler>()
                                                    .stopExpiryCheck();
                                                await _logoutUser(context);
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
                ),
              );
            }
            return Center(
                child: Column(
              children: <Widget>[
                const CircularProgressIndicator(),
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text('Return to login page'),
                ),
              ],
            ));
          },
        ),
      ),
    );
  }
}
