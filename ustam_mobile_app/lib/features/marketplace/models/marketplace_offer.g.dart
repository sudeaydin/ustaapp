// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarketplaceOfferImpl _$$MarketplaceOfferImplFromJson(
  Map<String, dynamic> json,
) => _$MarketplaceOfferImpl(
  id: json['id'] as String,
  listingId: json['listingId'] as String,
  proId: json['proId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'TRY',
  note: json['note'] as String?,
  etaDays: (json['etaDays'] as num?)?.toInt() ?? 3,
  createdAt: json['createdAt'] as String,
  status: json['status'] as String? ?? 'active',
  provider: json['provider'] == null
      ? null
      : OfferProvider.fromJson(json['provider'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$MarketplaceOfferImplToJson(
  _$MarketplaceOfferImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'listingId': instance.listingId,
  'proId': instance.proId,
  'amount': instance.amount,
  'currency': instance.currency,
  'note': instance.note,
  'etaDays': instance.etaDays,
  'createdAt': instance.createdAt,
  'status': instance.status,
  'provider': instance.provider,
};

_$OfferProviderImpl _$$OfferProviderImplFromJson(Map<String, dynamic> json) =>
    _$OfferProviderImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      speciality: json['speciality'] as String?,
    );

Map<String, dynamic> _$$OfferProviderImplToJson(_$OfferProviderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar': instance.avatar,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'speciality': instance.speciality,
    };
