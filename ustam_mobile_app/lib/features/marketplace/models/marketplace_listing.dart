import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_listing.freezed.dart';
part 'marketplace_listing.g.dart';

@freezed
class MarketplaceListing with _$MarketplaceListing {
  const factory MarketplaceListing({
    required String id,
    required String title,
    required String description,
    required String category,
    required ListingLocation location,
    required ListingBudget budget,
    required ListingDateRange dateRange,
    @Default([]) List<ListingAttachment> attachments,
    @Default('marketplace') String visibility,
    @Default('open') String status,
    required ListingUser postedBy,
    required DateTime postedAt,
    @Default(0) int bidsCount,
  }) = _MarketplaceListing;

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceListingFromJson(json);
}

@freezed
class ListingLocation with _$ListingLocation {
  const factory ListingLocation({
    required String city,
    required double lat,
    required double lng,
  }) = _ListingLocation;

  factory ListingLocation.fromJson(Map<String, dynamic> json) =>
      _$ListingLocationFromJson(json);
}

@freezed
class ListingBudget with _$ListingBudget {
  const factory ListingBudget({
    required String type, // 'fixed' or 'range'
    required double min,
    required double max,
    @Default('TRY') String currency,
  }) = _ListingBudget;

  factory ListingBudget.fromJson(Map<String, dynamic> json) =>
      _$ListingBudgetFromJson(json);
}

@freezed
class ListingDateRange with _$ListingDateRange {
  const factory ListingDateRange({
    required DateTime start,
    required DateTime end,
  }) = _ListingDateRange;

  factory ListingDateRange.fromJson(Map<String, dynamic> json) =>
      _$ListingDateRangeFromJson(json);
}

@freezed
class ListingAttachment with _$ListingAttachment {
  const factory ListingAttachment({
    required String url,
    required String type, // 'image' or 'pdf'
  }) = _ListingAttachment;

  factory ListingAttachment.fromJson(Map<String, dynamic> json) =>
      _$ListingAttachmentFromJson(json);
}

@freezed
class ListingUser with _$ListingUser {
  const factory ListingUser({
    required String userId,
    String? name,
    String? avatar,
  }) = _ListingUser;

  factory ListingUser.fromJson(Map<String, dynamic> json) =>
      _$ListingUserFromJson(json);
}