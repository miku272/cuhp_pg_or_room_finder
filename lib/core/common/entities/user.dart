class User {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String jwtToken;
  final String expiresIn;
  final List<String> property;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.jwtToken,
    required this.expiresIn,
    this.property = const [],
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? jwtToken,
    String? expiresIn,
    List<String>? property,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      jwtToken: jwtToken ?? this.jwtToken,
      expiresIn: expiresIn ?? this.expiresIn,
      property: property ?? this.property,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
