import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_offer.freezed.dart';
part 'marketplace_offer.g.dart';

@freezed
class MarketplaceOffer with _$MarketplaceOffer {
  const factory MarketplaceOffer({
    required String id,
    required String listingId,
    required String proId,
    required double amount,
    @Default('TRY') String currency,
    String? note,
    @Default(3) int etaDays,
    required DateTime createdAt,
    @Default('active') String status, // 'active', 'withdrawn', 'accepted', 'rejected'
    OfferProvider? provider,
  }) = _MarketplaceOffer;

  factory MarketplaceOffer.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceOfferFromJson(json);
}

@freezed
class OfferProvider with _$OfferProvider {
  const factory OfferProvider({
    required String id,
    required String name,
    String? avatar,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    String? speciality,
  }) = _OfferProvider;

  factory OfferProvider.fromJson(Map<String, dynamic> json) =>
      _$OfferProviderFromJson(json);
}