import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../core/common/widgets/property_card.dart';

import '../../data/models/property_filter.dart';
import '../bloc/home_bloc.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // num? _nearMeLat;
  // num? _nearMeLng;

  late User currentUser;

  @override
  void initState() {
    super.initState();

    final user = context.read<AppUserCubit>().user;

    if (user != null) {
      currentUser = user;
    } else {
      context.go('/login');
    }

    if (context.read<HomeBloc>().state.properties.isEmpty) {
      context.read<HomeBloc>().add(GetPropertiesByPaginationEvent(
            page: 1,
            limit: 10,
            filter: context.read<HomeBloc>().state.propertyFilter,
            token: currentUser.jwtToken,
          ));
    }
  }

  void _updateFilter(PropertyFilter newFilter) {
    context.read<HomeBloc>().add(UpdatePropertyFilterEvent(
          propertyFilter: newFilter,
          token: currentUser.jwtToken,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = context.watch<HomeBloc>().state.propertyFilter;
    final bool isNearMeSelected =
        currentFilter.nearMeLat != null && currentFilter.nearMeLng != null;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: <Widget>[
          CustomAppBar(
            appBarTitle: 'CUHP PG or Room Finder',
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  context.push('/chat');
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      ChoiceChip(
                        label: const Text('All'),
                        selected: currentFilter.propertyType == null,
                        onSelected: (selected) {
                          if (selected) {
                            _updateFilter(currentFilter.copyWith(
                              propertyType: null,
                            ));
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('PG'),
                        selected: currentFilter.propertyType == PropertyType.pg,
                        onSelected: (selected) {
                          if (selected) {
                            _updateFilter(currentFilter.copyWith(
                              propertyType: PropertyType.pg,
                            ));
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Rooms'),
                        selected:
                            currentFilter.propertyType == PropertyType.room,
                        onSelected: (selected) {
                          if (selected) {
                            _updateFilter(currentFilter.copyWith(
                              propertyType: PropertyType.room,
                            ));
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Near Me'),
                        selected: isNearMeSelected,
                        onSelected: (selected) {
                          if (selected) {
                            // TODO: Get user's location and update the filter

                            // _updateFilter(currentFilter.copyWith(
                            //   nearMeLat: _nearMeLat,
                            //   nearMeLng: _nearMeLng,
                            // ));
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search properties...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () async {
                        PropertyFilter? returnedFilter =
                            await showModalBottomSheet<PropertyFilter>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => FilterBottomSheet(
                            initialFilter: currentFilter,
                          ),
                        );

                        if (returnedFilter != null && context.mounted) {
                          final finalFilter = returnedFilter.copyWith(
                            nearMeLat: currentFilter.nearMeLat,
                            nearMeLng: currentFilter.nearMeLng,
                          );
                          _updateFilter(finalFilter);
                        }
                      },
                      icon: const Icon(Icons.tune),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Adjusted spacing
              ],
            ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final bool isLoadingMore =
                  state is HomeLoading && state.properties.isNotEmpty;
              final bool isInitialLoading =
                  state is HomeLoading && state.properties.isEmpty;

              if (isInitialLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is HomeLoadingFailure && state.properties.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              return Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Featured Properties',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: state.properties.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  context.push(
                                    '/my-listings/property/${state.properties[index].id}',
                                    extra: state.properties[index],
                                  );
                                },
                                child: PropertyCard(
                                  images: state.properties[index].images ?? [],
                                  propertyName:
                                      state.properties[index].propertyName ??
                                          '',
                                  address: state.properties[index]
                                          .propertyAddressLine1 ??
                                      '',
                                  price:
                                      state.properties[index].pricePerMonth ??
                                          0,
                                  isVerified:
                                      state.properties[index].isVerified ??
                                          false,
                                  propertyGenderAllowance:
                                      Property.genderAllowanceToString(
                                    state.properties[index]
                                            .propertyGenderAllowance ??
                                        GenderAllowance.coEd,
                                  ),
                                  services:
                                      state.properties[index].services ?? {},
                                  distanceFromUniversity: (state
                                              .properties[index]
                                              .distanceFromUniversity ??
                                          0)
                                      .toDouble(),
                                ),
                              );
                            },
                          ),
                          if (state.properties.isEmpty &&
                              !isInitialLoading &&
                              state is! HomeLoadingFailure)
                            const Center(
                              child: Text(
                                'No properties found matching your criteria.',
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    // TODO: Implement pagination trigger (e.g., on scroll)
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
