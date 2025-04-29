import '../../../../core/common/entities/property.dart';

class PaginatedPropertyResponse {
  final int results;
  final Pagination pagination;
  final Data data;

  const PaginatedPropertyResponse({
    required this.results,
    required this.pagination,
    required this.data,
  });

  factory PaginatedPropertyResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedPropertyResponse(
      results: json['results'] as int,
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
      data: Data.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalProperties;
  final int limit;

  const Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalProperties,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalProperties: json['totalProperties'] as int,
      limit: json['limit'] as int,
    );
  }
}

class Data {
  final List<Property> properties;

  Data({required this.properties});

  factory Data.fromJson(Map<String, dynamic> json) {
    final propertiesList = json['properties'] as List<dynamic>;

    final properties = propertiesList
        .map((propertyJson) =>
            Property.fromJson(propertyJson as Map<String, dynamic>))
        .toList();

    return Data(properties: properties);
  }
}
