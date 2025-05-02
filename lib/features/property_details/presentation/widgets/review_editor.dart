import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/entities/review.dart';
import '../bloc/property_details_bloc.dart';

class ReviewEditor extends StatefulWidget {
  final Review? review;
  final String propertyId;
  final String token;

  const ReviewEditor({
    this.review,
    required this.propertyId,
    required this.token,
    super.key,
  });

  @override
  State<ReviewEditor> createState() => _ReviewEditorState();
}

class _ReviewEditorState extends State<ReviewEditor> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _reviewController = TextEditingController();

  double _currentRating = 0.0;
  bool _isAnonymous = false;

  bool _showRatingError = false;
  bool get _isEditing => widget.review != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _reviewController.text = widget.review?.review ?? '';
      _currentRating = widget.review?.rating.toDouble() ?? 0.0;
      _isAnonymous = widget.review?.isAnonymous ?? false;
    }
  }

  void _submitOrUpdate() {
    if (!_formkey.currentState!.validate()) {
      return;
    }

    if (_currentRating == 0) {
      setState(() {
        _showRatingError = true;
      });
      return;
    }

    setState(() {
      _showRatingError = false;
    });

    if (_isEditing) {
      context.read<PropertyDetailsBloc>().add(
            UpdatePropertyReviewEvent(
              reviewId: widget.review!.id,
              rating: _currentRating.toInt(),
              review: _reviewController.text.trim().isEmpty
                  ? null
                  : _reviewController.text.trim(),
              isAnonymous: _isAnonymous,
              token: widget.token,
            ),
          );
    } else {
      context.read<PropertyDetailsBloc>().add(
            AddPropertyReviewEvent(
              propertyId: widget.propertyId,
              rating: _currentRating.toInt(),
              review: _reviewController.text.trim().isEmpty
                  ? null
                  : _reviewController.text.trim(),
              isAnonymous: _isAnonymous,
              token: widget.token,
            ),
          );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _formkey.currentState?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<PropertyDetailsBloc, PropertyDetailsState>(
      listener: (context, state) {
        if (state is PropertyReviewSuccess) {
          context.pop();
        } else if (state is PropertyReviewFailure) {
          final state = context.read<PropertyDetailsBloc>().state
              as PropertyReviewFailure;
          ScaffoldMessenger.of(context)
            ..clearSnackBars
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Edit Your Review' : 'Write a Review',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        context.pop();
                      },
                      tooltip: 'Cancel',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Your Rating*', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Center(
                  child: RatingBar.builder(
                    initialRating: _currentRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    unratedColor: Colors.amber.withAlpha(80),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _currentRating = rating;
                        if (rating > 0) {
                          _showRatingError = false;
                        }
                      });
                    },
                  ),
                ),
                if (_showRatingError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Text(
                        'Please select a rating',
                        style: TextStyle(
                            color: theme.colorScheme.error, fontSize: 12),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text('Your Review (Optional)',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLowest,
                  ),
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  maxLength: 500,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Post as Anonymous'),
                  value: _isAnonymous,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAnonymous = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: context.read<PropertyDetailsBloc>().state
                              is PropertyReviewLoading
                          ? null
                          : _submitOrUpdate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child:
                          Text(_isEditing ? 'Update Review' : 'Submit Review'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
