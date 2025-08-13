// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarketplaceListingImpl _$$MarketplaceListingImplFromJson(
  Map<String, dynamic> json,
) => _$MarketplaceListingImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  location: ListingLocation.fromJson(json['location'] as Map<String, dynamic>),
  budget: ListingBudget.fromJson(json['budget'] as Map<String, dynamic>),
  dateRange: ListingDateRange.fromJson(
    json['dateRange'] as Map<String, dynamic>,
  ),
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => ListingAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  visibility: json['visibility'] as String? ?? 'marketplace',
  status: json['status'] as String? ?? 'open',
  postedBy: ListingUser.fromJson(json['postedBy'] as Map<String, dynamic>),
  postedAt: json['postedAt'] as String,
  bidsCount: (json['bidsCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$MarketplaceListingImplToJson(
  _$MarketplaceListingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'location': instance.location,
  'budget': instance.budget,
  'dateRange': instance.dateRange,
  'attachments': instance.attachments,
  'visibility': instance.visibility,
  'status': instance.status,
  'postedBy': instance.postedBy,
  'postedAt': instance.postedAt,
  'bidsCount': instance.bidsCount,
};

_$ListingLocationImpl _$$ListingLocationImplFromJson(
  Map<String, dynamic> json,
) => _$ListingLocationImpl(
  city: json['city'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$$ListingLocationImplToJson(
  _$ListingLocationImpl instance,
) => <String, dynamic>{
  'city': instance.city,
  'lat': instance.lat,
  'lng': instance.lng,
};

_$ListingBudgetImpl _$$ListingBudgetImplFromJson(Map<String, dynamic> json) =>
    _$ListingBudgetImpl(
      type: json['type'] as String,
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
    );

Map<String, dynamic> _$$ListingBudgetImplToJson(_$ListingBudgetImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'min': instance.min,
      'max': instance.max,
      'currency': instance.currency,
    };

_$ListingDateRangeImpl _$$ListingDateRangeImplFromJson(
  Map<String, dynamic> json,
) => _$ListingDateRangeImpl(
  start: json['start'] as String,
  end: json['end'] as String,
);

Map<String, dynamic> _$$ListingDateRangeImplToJson(
  _$ListingDateRangeImpl instance,
) => <String, dynamic>{'start': instance.start, 'end': instance.end};

_$ListingAttachmentImpl _$$ListingAttachmentImplFromJson(
  Map<String, dynamic> json,
) => _$ListingAttachmentImpl(
  url: json['url'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$$ListingAttachmentImplToJson(
  _$ListingAttachmentImpl instance,
) => <String, dynamic>{'url': instance.url, 'type': instance.type};

_$ListingUserImpl _$$ListingUserImplFromJson(Map<String, dynamic> json) =>
    _$ListingUserImpl(
      userId: json['userId'] as String,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$ListingUserImplToJson(_$ListingUserImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'avatar': instance.avatar,
    };
