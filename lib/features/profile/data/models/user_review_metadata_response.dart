class UserReviewMetadataResponse {
  final int totalReviews;
  final double overallAverageRating;

  UserReviewMetadataResponse({
    required this.totalReviews,
    required this.overallAverageRating,
  });

  factory UserReviewMetadataResponse.fromJson(Map<String, dynamic> json) {
    return UserReviewMetadataResponse(
      totalReviews: json['totalReviews'],
      overallAverageRating: (json['overallAverageRating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReviews': totalReviews,
      'overallAverageRating': overallAverageRating,
    };
  }

  UserReviewMetadataResponse copyWith({
    int? totalReviews,
    double? overallAverageRating,
  }) {
    return UserReviewMetadataResponse(
      totalReviews: totalReviews ?? this.totalReviews,
      overallAverageRating: overallAverageRating ?? this.overallAverageRating,
    );
  }
}
