import 'dart:convert';

import '../../../../core/common/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    required super.isEmailVerified,
    required super.isPhoneVerified,
    required super.jwtToken,
    required super.expiresIn,
    super.property,
    super.createdAt,
    super.updatedAt,
  });

  @override
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'jwtToken': jwtToken,
      'expiresIn': expiresIn,
      'property': property,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      jwtToken: map['jwtToken'] ?? '',
      expiresIn: map['expiresIn'] ?? '',
      property: List<String>.from(map['property'] ?? const []),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, jwtToken: $jwtToken, expiresIn: $expiresIn, property: ${property.toString()} createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.isEmailVerified == isEmailVerified &&
        other.isPhoneVerified == isPhoneVerified &&
        other.jwtToken == jwtToken &&
        other.expiresIn == expiresIn &&
        other.property == property &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        isEmailVerified.hashCode ^
        isPhoneVerified.hashCode ^
        jwtToken.hashCode ^
        expiresIn.hashCode ^
        property.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
