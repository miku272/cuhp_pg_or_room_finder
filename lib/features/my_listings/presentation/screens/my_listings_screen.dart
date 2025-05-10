import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';

import '../../../../core/utils/jwt_expiration_handler.dart';
import '../../../../init_dependencies.dart';
import '../bloc/my_listings_bloc.dart';

import '../widgets/my_property_card.dart';
import '../widgets/no_property_listings.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  User? user;

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();

    user = context.read<AppUserCubit>().user;

    if (user == null) {
      context.pop();
      return;
    }

    _scrollController.addListener(_scrollListener);
    _fetchPropertiesIfNeeded();
  }

  void _fetchPropertiesIfNeeded() {
    if (user == null || user!.property.isEmpty) {
      return;
    }

    final currentProperties = context.read<MyListingsBloc>().state.properties;
    final currentPropertyIds = currentProperties.map((e) => e.id).toSet();

    final propertiesToFetch = user!.property
        .where((propertyId) => !currentPropertyIds.contains(propertyId))
        .take(_itemsPerPage)
        .toList();

    if (propertiesToFetch.isNotEmpty) {
      context.read<MyListingsBloc>().add(GetPropertiesByIdEvent(
            propertyIds: propertiesToFetch,
            token: user!.jwtToken,
          ));
    }
  }

  void _loadMoreProperties() {
    if (user == null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    _fetchPropertiesIfNeeded();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshProperties() async {
    if (user == null || user!.property.isEmpty) {
      return;
    }

    context.read<MyListingsBloc>().add(MyListingsReset());

    await Future.delayed(const Duration(microseconds: 1));

    _fetchPropertiesIfNeeded();
  }

  void _togglePropertyActivation(String propertyId) {
    context.read<MyListingsBloc>().add(TogglePropertyActivationEvent(
          propertyId: propertyId,
          token: user!.jwtToken,
        ));
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreProperties();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyListingsBloc, MyListingsState>(
      listener: (context, state) {
        if (state is MyListingsFailure) {
          if (state.status == 401) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );

            serviceLocator<JwtExpirationHandler>().stopExpiryCheck();
            context.read<AppUserCubit>().logoutUser(context);

            return;
          }
        }
      },
      builder: (context, state) {
        return Column(
          children: <Widget>[
            CustomAppBar(
              appBarTitle: 'My Listings',
              actions: <Widget>[
                IconButton(
                  onPressed: _refreshProperties,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProperties,
                child: Builder(builder: (context) {
                  if (state is MyListingsLoading && state.properties.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is! MyListingsLoading && state.properties.isEmpty) {
                    return const NoPropertyListings();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16).copyWith(
                      bottom: 60,
                    ),
                    itemCount: state.properties.length,
                    itemBuilder: (context, index) {
                      final property = state.properties[index];
                      return MyPropertyCard(
                        key: ValueKey(property.id),
                        property: property,
                        togglePropertyActivation: _togglePropertyActivation,
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
