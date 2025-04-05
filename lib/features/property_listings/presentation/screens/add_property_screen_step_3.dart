import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/image_utils.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';

import '../bloc/property_listings_bloc.dart';

import '../../data/models/property_form_data.dart';

class AddPropertyScreenStep3 extends StatefulWidget {
  final bool isEditing;
  final PropertyFormData propertyFormData;

  const AddPropertyScreenStep3({
    required this.isEditing,
    required this.propertyFormData,
    super.key,
  });

  @override
  State<AddPropertyScreenStep3> createState() => _AddPropertyScreenStep3State();
}

class _AddPropertyScreenStep3State extends State<AddPropertyScreenStep3> {
  User? user;

  final List<File> _selectedImages = [];
  final List<String> _imagesToDelete = [];

  final ImagePicker _picker = ImagePicker();
  final _pricePerMonthController = TextEditingController();

  var isCompressingImage = false;

  @override
  initState() {
    super.initState();

    final userState = context.read<AppUserCubit>().state;

    if (userState is AppUserLoggedin) {
      user = userState.user;
    } else {
      context.pop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _checkIfEditing();
      });
    });
  }

  void _checkIfEditing() {
    if (widget.isEditing) {
      _pricePerMonthController.text =
          widget.propertyFormData.pricePerMonth.toString();
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    setState(() {
      isCompressingImage = true;
    });
    if (pickedImages.isNotEmpty) {
      for (var image in pickedImages) {
        final String? compressedFilePath =
            await ImageUtils.compressImage(image.path);

        if (compressedFilePath != null) {
          setState(() {
            _selectedImages.add(File(compressedFilePath));
          });
        }
      }
    }
    setState(() {
      isCompressingImage = false;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _onSubmit() async {
    if (_pricePerMonthController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the monthly rent amount'),
        ),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
        ),
      );
      return;
    }

    if (_selectedImages.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only add up to 20 images'),
        ),
      );
      return;
    }

    final property = widget.propertyFormData.copyWith(
      pricePerMonth: int.parse(_pricePerMonthController.text),
    );

    context.read<PropertyListingsBloc>().add(PropertyListingAddEvent(
          propertyFormData: property,
          images: _selectedImages,
          token: user!.jwtToken,
          userId: user!.id,
          username: user!.name,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading your property...')),
    );
  }

  void _onUpdate() {
    if (_pricePerMonthController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the monthly rent amount'),
        ),
      );
      return;
    }

    final remainingExistingImages = widget.propertyFormData.images!
        .where((imageUrl) => !_imagesToDelete.contains(imageUrl))
        .toList();

    if (remainingExistingImages.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
        ),
      );
      return;
    }

    if (_selectedImages.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only add up to 20 images'),
        ),
      );
      return;
    }

    final property = widget.propertyFormData.copyWith(
      pricePerMonth: int.parse(_pricePerMonthController.text),
    );

    context.read<PropertyListingsBloc>().add(PropertyListingUpdateEvent(
          propertyId: widget.propertyFormData.id!,
          propertyFormData: property,
          images: _selectedImages,
          imagesToDelete: _imagesToDelete,
          token: user!.jwtToken,
          username: user!.name,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating your property...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !isCompressingImage &&
          context.read<PropertyListingsBloc>().state
              is! PropertyListingsLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.isEditing ? 'Update' : 'Add'} Your Property'),
            elevation: 0,
          ),
          body: BlocConsumer<PropertyListingsBloc, PropertyListingsState>(
            listener: (context, state) {
              if (state is AddPropertyListingsSuccess ||
                  state is UpdatePropertyListingsSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Property ${widget.isEditing ? 'updated' : 'added'} successfully'),
                  ),
                );

                context.go('/property-success', extra: {
                  'isEditing': widget.isEditing,
                });
              }

              if (state is AddPropertyListingsFailure ||
                  state is UpdatePropertyListingsFailure) {
                var message = '';

                if (state is AddPropertyListingsFailure) {
                  message = state.message;
                } else if (state is UpdatePropertyListingsFailure) {
                  message = state.message;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            builder: (context, state) => SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          size: 64,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Property Photos & Location',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step 3 of 3',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.isEditing)
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Previous Property Photos',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: widget
                                          .propertyFormData.images!.length,
                                      itemBuilder: (context, index) {
                                        final imageUrl = widget
                                            .propertyFormData.images![index];
                                        final isMarkedForDeletion =
                                            _imagesToDelete.contains(imageUrl);

                                        return Stack(
                                          children: [
                                            Container(
                                              width: 150,
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: CachedNetworkImage(
                                                  imageUrl: imageUrl,
                                                  fit: BoxFit.cover,
                                                  height: 200,
                                                  width: 150,
                                                  memCacheHeight: 400,
                                                  memCacheWidth: 300,
                                                  cacheKey: imageUrl,
                                                  maxHeightDiskCache: 400,
                                                  placeholder: (context, url) =>
                                                      Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      color: Colors.white,
                                                      width: 150,
                                                      height: 200,
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    color: theme
                                                        .colorScheme.surface,
                                                    child:
                                                        const Icon(Icons.error),
                                                  ),
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                        colorFilter:
                                                            isMarkedForDeletion
                                                                ? ColorFilter
                                                                    .mode(
                                                                    Colors.grey
                                                                        .withValues(
                                                                            alpha:
                                                                                0.7),
                                                                    BlendMode
                                                                        .saturation,
                                                                  )
                                                                : null,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 16,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (isMarkedForDeletion) {
                                                      _imagesToDelete
                                                          .remove(imageUrl);
                                                    } else {
                                                      _imagesToDelete
                                                          .add(imageUrl);
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: isMarkedForDeletion
                                                        ? theme
                                                            .colorScheme.primary
                                                            .withValues(
                                                                alpha: 0.8)
                                                        : theme
                                                            .colorScheme.error
                                                            .withValues(
                                                                alpha: 0.8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    isMarkedForDeletion
                                                        ? Icons.restore
                                                        : Icons.close,
                                                    size: 16,
                                                    color: theme
                                                        .colorScheme.onError,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (isMarkedForDeletion)
                                              Positioned(
                                                bottom: 8,
                                                left: 8,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme.error
                                                        .withValues(alpha: 0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    'Will be deleted',
                                                    style: TextStyle(
                                                      color: theme
                                                          .colorScheme.onError,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${widget.isEditing ? 'New ' : ''}Property Photos',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_selectedImages.isEmpty &&
                                    !isCompressingImage)
                                  InkWell(
                                    onTap: _pickImages,
                                    child: Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorScheme.outline,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: 48,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Add Property Photos',
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 200,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _selectedImages.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index ==
                                                    _selectedImages.length &&
                                                !isCompressingImage) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: InkWell(
                                                  onTap: _pickImages,
                                                  child: Container(
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: theme.colorScheme
                                                            .outline,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons
                                                            .add_photo_alternate_outlined,
                                                        size: 32,
                                                        color: theme.colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            return isCompressingImage
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300]!,
                                                      highlightColor:
                                                          Colors.grey[100]!,
                                                      child: Container(
                                                        width: 150,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Stack(
                                                    children: [
                                                      Container(
                                                        width: 150,
                                                        margin: const EdgeInsets
                                                            .only(right: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          image:
                                                              DecorationImage(
                                                            image: FileImage(
                                                                _selectedImages[
                                                                    index]),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 8,
                                                        right: 16,
                                                        child: GestureDetector(
                                                          onTap: () =>
                                                              _removeImage(
                                                                  index),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: theme
                                                                  .colorScheme
                                                                  .error
                                                                  .withValues(
                                                                      alpha:
                                                                          0.8),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Icon(
                                                              Icons.close,
                                                              size: 16,
                                                              color: theme
                                                                  .colorScheme
                                                                  .onError,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Rent',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _pricePerMonthController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Price per Month (₹)',
                                    hintText: 'Enter monthly rent amount',
                                    prefixIcon:
                                        const Icon(Icons.currency_rupee),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _pricePerMonthController.text = value;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isCompressingImage ||
                                        state is PropertyListingsLoading
                                    ? null
                                    : () => context.pop(),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Previous'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isCompressingImage ||
                                        state is PropertyListingsLoading
                                    ? null
                                    : widget.isEditing
                                        ? _onUpdate
                                        : _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  widget.isEditing ? 'Update' : 'Submit',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
