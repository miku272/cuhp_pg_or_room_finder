import './property.dart';

class SavedItem {
  final String id;
  final String userId;
  final Property property;

  SavedItem({
    required this.id,
    required this.userId,
    required this.property,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'property': property.toJson(),
    };
  }

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['_id'],
      userId: json['user'],
      property: Property.fromJson(json['property']),
    );
  }

  SavedItem copyWith({
    String? id,
    String? userId,
    Property? property,
  }) {
    return SavedItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      property: property ?? this.property,
    );
  }
}
