// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MarketplaceOffer _$MarketplaceOfferFromJson(Map<String, dynamic> json) {
  return _MarketplaceOffer.fromJson(json);
}

/// @nodoc
mixin _$MarketplaceOffer {
  String get id => throw _privateConstructorUsedError;
  String get listingId => throw _privateConstructorUsedError;
  String get proId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int get etaDays => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'active', 'withdrawn', 'accepted', 'rejected'
  OfferProvider? get provider => throw _privateConstructorUsedError;

  /// Serializes this MarketplaceOffer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketplaceOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketplaceOfferCopyWith<MarketplaceOffer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketplaceOfferCopyWith<$Res> {
  factory $MarketplaceOfferCopyWith(
    MarketplaceOffer value,
    $Res Function(MarketplaceOffer) then,
  ) = _$MarketplaceOfferCopyWithImpl<$Res, MarketplaceOffer>;
  @useResult
  $Res call({
    String id,
    String listingId,
    String proId,
    double amount,
    String currency,
    String? note,
    int etaDays,
    String createdAt,
    String status,
    OfferProvider? provider,
  });

  $OfferProviderCopyWith<$Res>? get provider;
}

/// @nodoc
class _$MarketplaceOfferCopyWithImpl<$Res, $Val extends MarketplaceOffer>
    implements $MarketplaceOfferCopyWith<$Res> {
  _$MarketplaceOfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketplaceOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? listingId = null,
    Object? proId = null,
    Object? amount = null,
    Object? currency = null,
    Object? note = freezed,
    Object? etaDays = null,
    Object? createdAt = null,
    Object? status = null,
    Object? provider = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            listingId: null == listingId
                ? _value.listingId
                : listingId // ignore: cast_nullable_to_non_nullable
                      as String,
            proId: null == proId
                ? _value.proId
                : proId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            etaDays: null == etaDays
                ? _value.etaDays
                : etaDays // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: freezed == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as OfferProvider?,
          )
          as $Val,
    );
  }

  /// Create a copy of MarketplaceOffer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OfferProviderCopyWith<$Res>? get provider {
    if (_value.provider == null) {
      return null;
    }

    return $OfferProviderCopyWith<$Res>(_value.provider!, (value) {
      return _then(_value.copyWith(provider: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MarketplaceOfferImplCopyWith<$Res>
    implements $MarketplaceOfferCopyWith<$Res> {
  factory _$$MarketplaceOfferImplCopyWith(
    _$MarketplaceOfferImpl value,
    $Res Function(_$MarketplaceOfferImpl) then,
  ) = __$$MarketplaceOfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String listingId,
    String proId,
    double amount,
    String currency,
    String? note,
    int etaDays,
    String createdAt,
    String status,
    OfferProvider? provider,
  });

  @override
  $OfferProviderCopyWith<$Res>? get provider;
}

/// @nodoc
class __$$MarketplaceOfferImplCopyWithImpl<$Res>
    extends _$MarketplaceOfferCopyWithImpl<$Res, _$MarketplaceOfferImpl>
    implements _$$MarketplaceOfferImplCopyWith<$Res> {
  __$$MarketplaceOfferImplCopyWithImpl(
    _$MarketplaceOfferImpl _value,
    $Res Function(_$MarketplaceOfferImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketplaceOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? listingId = null,
    Object? proId = null,
    Object? amount = null,
    Object? currency = null,
    Object? note = freezed,
    Object? etaDays = null,
    Object? createdAt = null,
    Object? status = null,
    Object? provider = freezed,
  }) {
    return _then(
      _$MarketplaceOfferImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        listingId: null == listingId
            ? _value.listingId
            : listingId // ignore: cast_nullable_to_non_nullable
                  as String,
        proId: null == proId
            ? _value.proId
            : proId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        etaDays: null == etaDays
            ? _value.etaDays
            : etaDays // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: freezed == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as OfferProvider?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketplaceOfferImpl implements _MarketplaceOffer {
  const _$MarketplaceOfferImpl({
    required this.id,
    required this.listingId,
    required this.proId,
    required this.amount,
    this.currency = 'TRY',
    this.note,
    this.etaDays = 3,
    required this.createdAt,
    this.status = 'active',
    this.provider,
  });

  factory _$MarketplaceOfferImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketplaceOfferImplFromJson(json);

  @override
  final String id;
  @override
  final String listingId;
  @override
  final String proId;
  @override
  final double amount;
  @override
  @JsonKey()
  final String currency;
  @override
  final String? note;
  @override
  @JsonKey()
  final int etaDays;
  @override
  final String createdAt;
  @override
  @JsonKey()
  final String status;
  // 'active', 'withdrawn', 'accepted', 'rejected'
  @override
  final OfferProvider? provider;

  @override
  String toString() {
    return 'MarketplaceOffer(id: $id, listingId: $listingId, proId: $proId, amount: $amount, currency: $currency, note: $note, etaDays: $etaDays, createdAt: $createdAt, status: $status, provider: $provider)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketplaceOfferImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.listingId, listingId) ||
                other.listingId == listingId) &&
            (identical(other.proId, proId) || other.proId == proId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.etaDays, etaDays) || other.etaDays == etaDays) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.provider, provider) ||
                other.provider == provider));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    listingId,
    proId,
    amount,
    currency,
    note,
    etaDays,
    createdAt,
    status,
    provider,
  );

  /// Create a copy of MarketplaceOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketplaceOfferImplCopyWith<_$MarketplaceOfferImpl> get copyWith =>
      __$$MarketplaceOfferImplCopyWithImpl<_$MarketplaceOfferImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketplaceOfferImplToJson(this);
  }
}

abstract class _MarketplaceOffer implements MarketplaceOffer {
  const factory _MarketplaceOffer({
    required final String id,
    required final String listingId,
    required final String proId,
    required final double amount,
    final String currency,
    final String? note,
    final int etaDays,
    required final String createdAt,
    final String status,
    final OfferProvider? provider,
  }) = _$MarketplaceOfferImpl;

  factory _MarketplaceOffer.fromJson(Map<String, dynamic> json) =
      _$MarketplaceOfferImpl.fromJson;

  @override
  String get id;
  @override
  String get listingId;
  @override
  String get proId;
  @override
  double get amount;
  @override
  String get currency;
  @override
  String? get note;
  @override
  int get etaDays;
  @override
  String get createdAt;
  @override
  String get status; // 'active', 'withdrawn', 'accepted', 'rejected'
  @override
  OfferProvider? get provider;

  /// Create a copy of MarketplaceOffer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketplaceOfferImplCopyWith<_$MarketplaceOfferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OfferProvider _$OfferProviderFromJson(Map<String, dynamic> json) {
  return _OfferProvider.fromJson(json);
}

/// @nodoc
mixin _$OfferProvider {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  String? get speciality => throw _privateConstructorUsedError;

  /// Serializes this OfferProvider to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OfferProvider
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OfferProviderCopyWith<OfferProvider> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfferProviderCopyWith<$Res> {
  factory $OfferProviderCopyWith(
    OfferProvider value,
    $Res Function(OfferProvider) then,
  ) = _$OfferProviderCopyWithImpl<$Res, OfferProvider>;
  @useResult
  $Res call({
    String id,
    String name,
    String? avatar,
    double rating,
    int reviewCount,
    String? speciality,
  });
}

/// @nodoc
class _$OfferProviderCopyWithImpl<$Res, $Val extends OfferProvider>
    implements $OfferProviderCopyWith<$Res> {
  _$OfferProviderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OfferProvider
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatar = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? speciality = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatar: freezed == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            speciality: freezed == speciality
                ? _value.speciality
                : speciality // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OfferProviderImplCopyWith<$Res>
    implements $OfferProviderCopyWith<$Res> {
  factory _$$OfferProviderImplCopyWith(
    _$OfferProviderImpl value,
    $Res Function(_$OfferProviderImpl) then,
  ) = __$$OfferProviderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? avatar,
    double rating,
    int reviewCount,
    String? speciality,
  });
}

/// @nodoc
class __$$OfferProviderImplCopyWithImpl<$Res>
    extends _$OfferProviderCopyWithImpl<$Res, _$OfferProviderImpl>
    implements _$$OfferProviderImplCopyWith<$Res> {
  __$$OfferProviderImplCopyWithImpl(
    _$OfferProviderImpl _value,
    $Res Function(_$OfferProviderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OfferProvider
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatar = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? speciality = freezed,
  }) {
    return _then(
      _$OfferProviderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatar: freezed == avatar
            ? _value.avatar
            : avatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        speciality: freezed == speciality
            ? _value.speciality
            : speciality // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OfferProviderImpl implements _OfferProvider {
  const _$OfferProviderImpl({
    required this.id,
    required this.name,
    this.avatar,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.speciality,
  });

  factory _$OfferProviderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfferProviderImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? avatar;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  final String? speciality;

  @override
  String toString() {
    return 'OfferProvider(id: $id, name: $name, avatar: $avatar, rating: $rating, reviewCount: $reviewCount, speciality: $speciality)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfferProviderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.speciality, speciality) ||
                other.speciality == speciality));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    avatar,
    rating,
    reviewCount,
    speciality,
  );

  /// Create a copy of OfferProvider
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfferProviderImplCopyWith<_$OfferProviderImpl> get copyWith =>
      __$$OfferProviderImplCopyWithImpl<_$OfferProviderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OfferProviderImplToJson(this);
  }
}

abstract class _OfferProvider implements OfferProvider {
  const factory _OfferProvider({
    required final String id,
    required final String name,
    final String? avatar,
    final double rating,
    final int reviewCount,
    final String? speciality,
  }) = _$OfferProviderImpl;

  factory _OfferProvider.fromJson(Map<String, dynamic> json) =
      _$OfferProviderImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get avatar;
  @override
  double get rating;
  @override
  int get reviewCount;
  @override
  String? get speciality;

  /// Create a copy of OfferProvider
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfferProviderImplCopyWith<_$OfferProviderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
