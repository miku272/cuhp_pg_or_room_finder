import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../core/common/widgets/property_card.dart';

import '../../data/models/property_filter.dart';

import '../bloc/home_bloc.dart';

import '../widgets/autocomplete_suggestion_item.dart';
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
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchRowKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  bool _isSearchFieldFocused = false;

  @override
  void initState() {
    super.initState();

    final user = context.read<AppUserCubit>().user;

    if (user != null) {
      currentUser = user;
    } else {
      context.go('/login');

      return;
    }

    _searchFocusNode.addListener(_onFocusChange);
    _scrollController.addListener(_onScroll);

    if (context.read<HomeBloc>().state.properties.isEmpty) {
      context.read<HomeBloc>().add(GetPropertiesByPaginationEvent(
            page: 1,
            limit: 10,
            filter: context.read<HomeBloc>().state.propertyFilter,
            token: currentUser.jwtToken,
          ));
    }
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isSearchFieldFocused = _searchFocusNode.hasFocus;
        print(
            '--- Focus Changed via listener, _isSearchFieldFocused: $_isSearchFieldFocused ---');
      });
      if (!_isSearchFieldFocused &&
          (_searchController.text.isNotEmpty ||
              context
                  .read<HomeBloc>()
                  .state
                  .autocomleteProperties
                  .isNotEmpty)) {
        // If focus is lost and there was text or suggestions, clear suggestions.
        context.read<HomeBloc>().add(ClearAutocompletePropertiesEvent());
      }
    }
  }

  void _onScroll() {
    if (_isBottom) {
      final homeBloc = context.read<HomeBloc>();
      final currentState = homeBloc.state;

      if (!currentState.hasReachedMax && currentState is! HomeLoading) {
        homeBloc.add(GetPropertiesByPaginationEvent(
          page: currentState.currentPage + 1,
          limit: 10,
          filter: currentState.propertyFilter,
          token: currentUser.jwtToken,
        ));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) {
      return false;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled'),
            ),
          );
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied'),
              ),
            );
        }
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                    'Location permission are permanently denied. Please enable them in the app settings.'),
              ),
            );
          await Geolocator.openAppSettings();
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permission are permanently denied. Please enable them in the app settings.'),
            ),
          );
        await Geolocator.openAppSettings();
      }
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('Failed to get current location.')),
          );
      }

      return null;
    }
  }

  void _updateFilter(PropertyFilter newFilter) {
    context.read<HomeBloc>().add(UpdatePropertyFilterEvent(
          propertyFilter: newFilter,
          token: currentUser.jwtToken,
        ));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = context.watch<HomeBloc>().state.propertyFilter;

    return GestureDetector(
      onTap: () {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      child: Stack(
        children: <Widget>[
          Column(
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
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Row(
                      key: _searchRowKey,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Search properties...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (query) {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }

                              _debounce =
                                  Timer(const Duration(milliseconds: 500), () {
                                if (query.trim().isNotEmpty) {
                                  context.read<HomeBloc>().add(
                                        GetAutocompletePropertiesEvent(
                                          term: query.trim(),
                                          token: currentUser.jwtToken,
                                        ),
                                      );
                                } else {
                                  context.read<HomeBloc>().add(
                                        ClearAutocompletePropertiesEvent(),
                                      );
                                }
                              });
                            },
                            onSubmitted: (query) {
                              _searchFocusNode.unfocus();

                              context.read<HomeBloc>().add(
                                    ClearAutocompletePropertiesEvent(),
                                  );
                            },
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
                                propertyType: returnedFilter.propertyType,
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
                                  nearMeLat: currentFilter.nearMeLat,
                                  nearMeLng: currentFilter.nearMeLng,
                                ));
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('PG'),
                            selected:
                                currentFilter.propertyType == PropertyType.pg,
                            onSelected: (selected) {
                              if (selected) {
                                _updateFilter(currentFilter.copyWith(
                                  propertyType: PropertyType.pg,
                                  nearMeLat: currentFilter.nearMeLat,
                                  nearMeLng: currentFilter.nearMeLng,
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
                                  nearMeLat: currentFilter.nearMeLat,
                                  nearMeLng: currentFilter.nearMeLng,
                                ));
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Near Me'),
                            selected: context
                                        .watch<HomeBloc>()
                                        .state
                                        .propertyFilter
                                        .nearMeLat !=
                                    null &&
                                context
                                        .watch<HomeBloc>()
                                        .state
                                        .propertyFilter
                                        .nearMeLng !=
                                    null,
                            onSelected: (selected) async {
                              final currentFilter =
                                  context.read<HomeBloc>().state.propertyFilter;

                              final isSelected =
                                  currentFilter.nearMeLat != null &&
                                      currentFilter.nearMeLng != null;

                              if (isSelected) {
                                _updateFilter(currentFilter.copyWith(
                                  propertyType: currentFilter.propertyType,
                                  nearMeLat: null,
                                  nearMeLng: null,
                                ));

                                return;
                              }

                              final Position? position =
                                  await _getCurrentLocation();

                              if (position != null) {
                                _updateFilter(currentFilter.copyWith(
                                  propertyType: currentFilter.propertyType,
                                  nearMeLat: position.latitude,
                                  nearMeLng: position.longitude,
                                ));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
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
                      controller: _scrollController,
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
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.properties.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    key: ValueKey(
                                      state.properties[index].id,
                                    ),
                                    onTap: () {
                                      context.push(
                                        '/my-listings/property/${state.properties[index].id}',
                                        extra: state.properties[index],
                                      );
                                    },
                                    child: PropertyCard(
                                      showFavouriteButton:
                                          state.properties[index].ownerId !=
                                              currentUser.id,
                                      isSaved:
                                          state.properties[index].isSaved ??
                                              false,
                                      onFavoritePressed: () {
                                        if (state.properties[index].isSaved ==
                                            false) {
                                          context.read<HomeBloc>().add(
                                                HomeAddSavedItemEvent(
                                                  propertyId: state
                                                          .properties[index]
                                                          .id ??
                                                      '',
                                                  token: currentUser.jwtToken,
                                                ),
                                              );
                                        } else if (state
                                                .properties[index].isSaved ==
                                            true) {
                                          context.read<HomeBloc>().add(
                                                HomeRemoveSavedItemEvent(
                                                  propertyId: state
                                                          .properties[index]
                                                          .id ??
                                                      '',
                                                  token: currentUser.jwtToken,
                                                ),
                                              );
                                        }
                                      },
                                      images:
                                          state.properties[index].images ?? [],
                                      propertyName: state
                                              .properties[index].propertyName ??
                                          '',
                                      address: state.properties[index]
                                              .propertyAddressLine1 ??
                                          '',
                                      price: state.properties[index]
                                              .pricePerMonth ??
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
                                          state.properties[index].services ??
                                              {},
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
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final bool shouldShowSuggestions =
                  _searchController.text.isNotEmpty &&
                      _isSearchFieldFocused &&
                      (state.autocomleteProperties.isNotEmpty ||
                          state is HomeGetAutocompletePropertiesLoading);

              if (!shouldShowSuggestions) {
                return const SizedBox.shrink();
              }

              RenderBox? searchRowRenderBox = _searchRowKey.currentContext
                  ?.findRenderObject() as RenderBox?;
              Offset? searchRowOffset =
                  searchRowRenderBox?.localToGlobal(Offset.zero);
              Size? searchRowSize = searchRowRenderBox?.size;

              if (searchRowOffset == null || searchRowSize == null) {
                return const SizedBox.shrink();
              }

              // Calculate position for the overlay
              // This positions the overlay relative to the screen.
              final topPosition = searchRowOffset.dy + searchRowSize.height;
              final leftPosition = searchRowOffset.dx;
              final suggestionWidth = searchRowSize.width;

              return Positioned(
                top: topPosition + 8.0,
                left: leftPosition,
                width: suggestionWidth,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  constraints: const BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, 20),
                        blurRadius: 25.0,
                        spreadRadius: -5.0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, 8),
                        blurRadius: 10.0,
                        spreadRadius: -6.0,
                      ),
                    ],
                  ),
                  child: (state is HomeGetAutocompletePropertiesLoading &&
                          state.autocomleteProperties.isEmpty)
                      ? const Center(
                          child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: state.autocomleteProperties.length,
                          itemBuilder: (context, index) {
                            final property = state.autocomleteProperties[index];
                            return AutocompleteSuggestionItem(
                              property: property,
                              onTap: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                context
                                    .read<HomeBloc>()
                                    .add(ClearAutocompletePropertiesEvent());
                                context.push(
                                  '/my-listings/property/${property.id}',
                                  extra: property,
                                );
                              },
                            );
                          },
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
