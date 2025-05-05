import '../../../../core/common/entities/saved_item.dart';

class GetSavedItemsResponseModel {
  final int results;
  final PaginationData paginationData;
  final List<SavedItem> savedItems;

  GetSavedItemsResponseModel({
    required this.results,
    required this.paginationData,
    required this.savedItems,
  });

  factory GetSavedItemsResponseModel.fromJson(Map<String, dynamic> json) {
    return GetSavedItemsResponseModel(
      results: json['results'] as int,
      paginationData: PaginationData.fromJson(json['pagination']),
      savedItems: (json['data']['saved'] as List<dynamic>)
          .map((item) => SavedItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results,
      'pagination': paginationData.toJson(),
      'data': {
        'saved': savedItems.map((item) => item.toJson()).toList(),
      },
    };
  }

  GetSavedItemsResponseModel copyWith({
    int? results,
    PaginationData? paginationData,
    List<SavedItem>? savedItems,
  }) {
    return GetSavedItemsResponseModel(
      results: results ?? this.results,
      paginationData: paginationData ?? this.paginationData,
      savedItems: savedItems ?? this.savedItems,
    );
  }
}

class PaginationData {
  final int currentPage;
  final int totalPages;
  final int totalSaved;
  final int limit;

  PaginationData({
    required this.currentPage,
    required this.totalPages,
    required this.totalSaved,
    required this.limit,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalSaved: json['totalSaved'] as int,
      limit: json['limit'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalSaved': totalSaved,
      'limit': limit,
    };
  }

  PaginationData copyWith({
    int? currentPage,
    int? totalPages,
    int? totalSaved,
    int? limit,
  }) {
    return PaginationData(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalSaved: totalSaved ?? this.totalSaved,
      limit: limit ?? this.limit,
    );
  }
}
