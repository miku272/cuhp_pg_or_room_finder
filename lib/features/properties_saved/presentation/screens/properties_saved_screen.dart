import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../init_dependencies.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/common/widgets/property_card.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../core/utils/jwt_expiration_handler.dart';

import '../widgets/no_properties_saved.dart';
import '../bloc/properties_saved_bloc.dart';

class PropertiesSavedScreen extends StatefulWidget {
  const PropertiesSavedScreen({super.key});

  @override
  State<PropertiesSavedScreen> createState() => _PropertiesSavedScreenState();
}

class _PropertiesSavedScreenState extends State<PropertiesSavedScreen> {
  User? user;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    user = context.read<AppUserCubit>().user;

    if (user == null) {
      context.pop();
      return;
    }

    final propertiesSavedState = context.read<PropertiesSavedBloc>().state;
    if (propertiesSavedState is PropertiesSavedInitial ||
        propertiesSavedState.savedItems.isEmpty) {
      context.read<PropertiesSavedBloc>().add(
            GetSavedItemsEvent(
              page: 1,
              limit: 10,
              token: user!.jwtToken,
            ),
          );
    }

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final propertiesSavedState = context.read<PropertiesSavedBloc>().state;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        propertiesSavedState is! GetPropertiesSavedLoading &&
        propertiesSavedState.savedItems.isNotEmpty &&
        !propertiesSavedState.hasReachedMax) {
      context.read<PropertiesSavedBloc>().add(
            GetSavedItemsEvent(
              page: propertiesSavedState.currentPage + 1,
              limit: 10,
              token: user!.jwtToken,
            ),
          );
    }
  }

  Future<void> _refreshSavedProperties() async {
    if (user == null) {
      return;
    }

    context.read<PropertiesSavedBloc>().add(PropertiesSavedResetEvent());

    await Future.delayed(const Duration(microseconds: 1));

    if (mounted) {
      context.read<PropertiesSavedBloc>().add(GetSavedItemsEvent(
            page: 1,
            limit: 10,
            token: user!.jwtToken,
          ));
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
    return Column(
      children: <Widget>[
        CustomAppBar(
          appBarTitle: 'My saved properties',
          actions: <Widget>[
            IconButton(
              onPressed: _refreshSavedProperties,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        BlocConsumer<PropertiesSavedBloc, PropertiesSavedState>(
          listener: (context, state) {
            if (state is PropertiesSavedFailure) {
              print('PropertiesSavedFailure: ${state.message}');

              if (state.status == 401) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );

                serviceLocator<JwtExpirationHandler>().stopExpiryCheck();
                context.read<AppUserCubit>().logoutUser(context);

                return;
              }
            }

            if (state is GetPropertiesSavedFailure) {
              print('GetPropertiesSavedFailure: ${state.message}');

              if (state.status == 401) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );

                serviceLocator<JwtExpirationHandler>().stopExpiryCheck();
                context.read<AppUserCubit>().logoutUser(context);

                return;
              }
            }
          },
          builder: (context, state) {
            if (state is GetPropertiesSavedLoading &&
                state.savedItems.isEmpty) {
              return const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is! GetPropertiesSavedLoading &&
                state.savedItems.isEmpty) {
              return const Center(
                child: NoPropertySaved(),
              );
            }

            return Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshSavedProperties,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.savedItems.length +
                      (state is GetPropertiesSavedLoading ? 1 : 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) {
                    if (index >= state.savedItems.length) {
                      return state is GetPropertiesSavedLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    }

                    final savedProperty = state.savedItems[index].property;

                    return GestureDetector(
                      onTap: () {
                        context.push(
                          '/my-listings/property/${savedProperty.id}',
                          extra: savedProperty,
                        );
                      },
                      child: PropertyCard(
                        key: ValueKey<String>(savedProperty.id ?? ''),
                        isSaved: true,
                        onFavoritePressed: () {
                          context.read<PropertiesSavedBloc>().add(
                                RemoveSavedItemEvent(
                                  savedItemId: state.savedItems[index].id,
                                  token: user!.jwtToken,
                                ),
                              );
                        },
                        images: savedProperty.images ?? [],
                        propertyName: savedProperty.propertyName ?? '',
                        address: savedProperty.propertyAddressLine1 ?? '',
                        distanceFromUniversity:
                            savedProperty.distanceFromUniversity?.toDouble() ??
                                0.0,
                        isVerified: savedProperty.isVerified ?? false,
                        price: savedProperty.pricePerMonth ?? 0,
                        propertyGenderAllowance:
                            Property.genderAllowanceToString(
                          savedProperty.propertyGenderAllowance!,
                        ),
                        services: savedProperty.services ?? <String, bool>{},
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
