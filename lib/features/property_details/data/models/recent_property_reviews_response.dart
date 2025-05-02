import '../../../../core/common/entities/review.dart';

class RecentPropertyReviewsResponse {
  final int totalReviews;
  final List<Review> reviews;

  const RecentPropertyReviewsResponse({
    required this.totalReviews,
    required this.reviews,
  });

  factory RecentPropertyReviewsResponse.fromJson(Map<String, dynamic> json) {
    return RecentPropertyReviewsResponse(
      totalReviews: json['totalReviews'] as int,
      reviews: (json['data']['reviews'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReviews': totalReviews,
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }

  RecentPropertyReviewsResponse copyWith({
    int? totalReviews,
    List<Review>? reviews,
  }) {
    return RecentPropertyReviewsResponse(
      totalReviews: totalReviews ?? this.totalReviews,
      reviews: reviews ?? this.reviews,
    );
  }
}
