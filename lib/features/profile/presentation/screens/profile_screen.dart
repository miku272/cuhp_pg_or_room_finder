import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';

import '../widgets/verification_pill.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                                    ? Text(state.user.phone!)
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
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.home_outlined),
                                title: const Text('My Listings'),
                                trailing: const Text('2 Active'),
                              ),
                              const Divider(),
                              ListTile(
                                title: const Text('Total Listings'),
                                trailing: const Text('5'),
                              ),
                              ListTile(
                                title: const Text('Active Listings'),
                                trailing: const Text('2'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reviews Card
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.star_outline),
                                title: const Text('Reviews'),
                                trailing: const Text('4.5★'),
                              ),
                              const Divider(),
                              ListTile(
                                title: const Text('Total Reviews'),
                                trailing: const Text('12'),
                              ),
                            ],
                          ),
                        ),
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
