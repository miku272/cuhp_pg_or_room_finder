class Review {
  final String id;
  final PropertyInfo property;
  final UserInfo? user;
  final int rating;
  final String? review;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.property,
    this.user,
    required this.rating,
    this.review,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'property': property.toJson(),
      'user': user?.toJson(),
      'rating': rating,
      'review': review,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] as String,
      property: PropertyInfo.fromJson(json['property']),
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      rating: json['rating'] as int,
      review: json['review'] as String?,
      isAnonymous: json['isAnonymous'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Review copyWith({
    String? id,
    PropertyInfo? property,
    UserInfo? user,
    int? rating,
    String? review,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      property: property ?? this.property,
      user: user ?? this.user,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PropertyInfo {
  final String id;
  final String propertyName;

  PropertyInfo({
    required this.id,
    required this.propertyName,
  });

  Map<String, String> toJson() {
    return {
      '_id': id,
      'propertyName': propertyName,
    };
  }

  factory PropertyInfo.fromJson(Map<String, dynamic> json) {
    return PropertyInfo(
      id: json['_id'] as String,
      propertyName: json['propertyName'] as String,
    );
  }

  PropertyInfo copyWith({
    String? id,
    String? propertyName,
  }) {
    return PropertyInfo(
      id: id ?? this.id,
      propertyName: propertyName ?? this.propertyName,
    );
  }
}

class UserInfo {
  final String? id;
  final String name;

  UserInfo({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] as String?,
      name: json['name'] as String,
    );
  }

  UserInfo copyWith({
    String? id,
    String? name,
  }) {
    return UserInfo(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
