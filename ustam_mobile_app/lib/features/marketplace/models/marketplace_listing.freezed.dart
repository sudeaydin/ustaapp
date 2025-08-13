// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MarketplaceListing _$MarketplaceListingFromJson(Map<String, dynamic> json) {
  return _MarketplaceListing.fromJson(json);
}

/// @nodoc
mixin _$MarketplaceListing {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  ListingLocation get location => throw _privateConstructorUsedError;
  ListingBudget get budget => throw _privateConstructorUsedError;
  ListingDateRange get dateRange => throw _privateConstructorUsedError;
  List<ListingAttachment> get attachments => throw _privateConstructorUsedError;
  String get visibility => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  ListingUser get postedBy => throw _privateConstructorUsedError;
  String get postedAt => throw _privateConstructorUsedError;
  int get bidsCount => throw _privateConstructorUsedError;

  /// Serializes this MarketplaceListing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketplaceListing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketplaceListingCopyWith<MarketplaceListing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketplaceListingCopyWith<$Res> {
  factory $MarketplaceListingCopyWith(
    MarketplaceListing value,
    $Res Function(MarketplaceListing) then,
  ) = _$MarketplaceListingCopyWithImpl<$Res, MarketplaceListing>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String category,
    ListingLocation location,
    ListingBudget budget,
    ListingDateRange dateRange,
    List<ListingAttachment> attachments,
    String visibility,
    String status,
    ListingUser postedBy,
    String postedAt,
    int bidsCount,
  });

  $ListingLocationCopyWith<$Res> get location;
  $ListingBudgetCopyWith<$Res> get budget;
  $ListingDateRangeCopyWith<$Res> get dateRange;
  $ListingUserCopyWith<$Res> get postedBy;
}

/// @nodoc
class _$MarketplaceListingCopyWithImpl<$Res, $Val extends MarketplaceListing>
    implements $MarketplaceListingCopyWith<$Res> {
  _$MarketplaceListingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketplaceListing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? location = null,
    Object? budget = null,
    Object? dateRange = null,
    Object? attachments = null,
    Object? visibility = null,
    Object? status = null,
    Object? postedBy = null,
    Object? postedAt = null,
    Object? bidsCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as ListingLocation,
            budget: null == budget
                ? _value.budget
                : budget // ignore: cast_nullable_to_non_nullable
                      as ListingBudget,
            dateRange: null == dateRange
                ? _value.dateRange
                : dateRange // ignore: cast_nullable_to_non_nullable
                      as ListingDateRange,
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<ListingAttachment>,
            visibility: null == visibility
                ? _value.visibility
                : visibility // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            postedBy: null == postedBy
                ? _value.postedBy
                : postedBy // ignore: cast_nullable_to_non_nullable
                      as ListingUser,
            postedAt: null == postedAt
                ? _value.postedAt
                : postedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            bidsCount: null == bidsCount
                ? _value.bidsCount
                : bidsCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of MarketplaceListing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ListingLocationCopyWith<$Res> get location {
    return $ListingLocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of MarketplaceListing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ListingBudgetCopyWith<$Res> get budget {
    return $ListingBudgetCopyWith<$Res>(_value.budget, (value) {
      return _then(_value.copyWith(budget: value) as $Val);
    });
  }

  /// Create a copy of MarketplaceListing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ListingDateRangeCopyWith<$Res> get dateRange {
    return $ListingDateRangeCopyWith<$Res>(_value.dateRange, (value) {
      return _then(_value.copyWith(dateRange: value) as $Val);
    });
  }

  /// Create a copy of MarketplaceListing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ListingUserCopyWith<$Res> get postedBy {
    return $ListingUserCopyWith<$Res>(_value.postedBy, (value) {
      return _then(_value.copyWith(postedBy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MarketplaceListingImplCopyWith<$Res>
    implements $MarketplaceListingCopyWith<$Res> {
  factory _$$MarketplaceListingImplCopyWith(
    _$MarketplaceListingImpl value,
    $Res Function(_$MarketplaceListingImpl) then,
  ) = __$$MarketplaceListingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String category,
    ListingLocation location,
    ListingBudget budget,
    ListingDateRange dateRange,
    List<ListingAttachment> attachments,
    String visibility,
    String status,
    ListingUser postedBy,
    String postedAt,
    int bidsCount,
  });

  @override
  $ListingLocationCopyWith<$Res> get location;
  @override
  $ListingBudgetCopyWith<$Res> get budget;
  @override
  $ListingDateRangeCopyWith<$Res> get dateRange;
  @override
  $ListingUserCopyWith<$Res> get postedBy;
}

/// @nodoc
class __$$MarketplaceListingImplCopyWithImpl<$Res>
    extends _$MarketplaceListingCopyWithImpl<$Res, _$MarketplaceListingImpl>
    implements _$$MarketplaceListingImplCopyWith<$Res> {
  __$$MarketplaceListingImplCopyWithImpl(
    _$MarketplaceListingImpl _value,
    $Res Function(_$MarketplaceListingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketplaceListing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? location = null,
    Object? budget = null,
    Object? dateRange = null,
    Object? attachments = null,
    Object? visibility = null,
    Object? status = null,
    Object? postedBy = null,
    Object? postedAt = null,
    Object? bidsCount = null,
  }) {
    return _then(
      _$MarketplaceListingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as ListingLocation,
        budget: null == budget
            ? _value.budget
            : budget // ignore: cast_nullable_to_non_nullable
                  as ListingBudget,
        dateRange: null == dateRange
            ? _value.dateRange
            : dateRange // ignore: cast_nullable_to_non_nullable
                  as ListingDateRange,
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<ListingAttachment>,
        visibility: null == visibility
            ? _value.visibility
            : visibility // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        postedBy: null == postedBy
            ? _value.postedBy
            : postedBy // ignore: cast_nullable_to_non_nullable
                  as ListingUser,
        postedAt: null == postedAt
            ? _value.postedAt
            : postedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        bidsCount: null == bidsCount
            ? _value.bidsCount
            : bidsCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketplaceListingImpl implements _MarketplaceListing {
  const _$MarketplaceListingImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.budget,
    required this.dateRange,
    final List<ListingAttachment> attachments = const [],
    this.visibility = 'marketplace',
    this.status = 'open',
    required this.postedBy,
    required this.postedAt,
    this.bidsCount = 0,
  }) : _attachments = attachments;

  factory _$MarketplaceListingImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketplaceListingImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  @override
  final ListingLocation location;
  @override
  final ListingBudget budget;
  @override
  final ListingDateRange dateRange;
  final List<ListingAttachment> _attachments;
  @override
  @JsonKey()
  List<ListingAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  @JsonKey()
  final String visibility;
  @override
  @JsonKey()
  final String status;
  @override
  final ListingUser postedBy;
  @override
  final String postedAt;
  @override
  @JsonKey()
  final int bidsCount;

  @override
  String toString() {
    return 'MarketplaceListing(id: $id, title: $title, description: $description, category: $category, location: $location, budget: $budget, dateRange: $dateRange, attachments: $attachments, visibility: $visibility, status: $status, postedBy: $postedBy, postedAt: $postedAt, bidsCount: $bidsCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketplaceListingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.postedBy, postedBy) ||
                other.postedBy == postedBy) &&
            (identical(other.postedAt, postedAt) ||
                other.postedAt == postedAt) &&
            (identical(other.bidsCount, bidsCount) ||
                other.bidsCount == bidsCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    category,
    location,
    budget,
    dateRange,
    const DeepCollectionEquality().hash(_attachments),
    visibility,
    status,
    postedBy,
    postedAt,
    bidsCount,
  );

  /// Create a copy of MarketplaceListing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketplaceListingImplCopyWith<_$MarketplaceListingImpl> get copyWith =>
      __$$MarketplaceListingImplCopyWithImpl<_$MarketplaceListingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketplaceListingImplToJson(this);
  }
}

abstract class _MarketplaceListing implements MarketplaceListing {
  const factory _MarketplaceListing({
    required final String id,
    required final String title,
    required final String description,
    required final String category,
    required final ListingLocation location,
    required final ListingBudget budget,
    required final ListingDateRange dateRange,
    final List<ListingAttachment> attachments,
    final String visibility,
    final String status,
    required final ListingUser postedBy,
    required final String postedAt,
    final int bidsCount,
  }) = _$MarketplaceListingImpl;

  factory _MarketplaceListing.fromJson(Map<String, dynamic> json) =
      _$MarketplaceListingImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  ListingLocation get location;
  @override
  ListingBudget get budget;
  @override
  ListingDateRange get dateRange;
  @override
  List<ListingAttachment> get attachments;
  @override
  String get visibility;
  @override
  String get status;
  @override
  ListingUser get postedBy;
  @override
  String get postedAt;
  @override
  int get bidsCount;

  /// Create a copy of MarketplaceListing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketplaceListingImplCopyWith<_$MarketplaceListingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingLocation _$ListingLocationFromJson(Map<String, dynamic> json) {
  return _ListingLocation.fromJson(json);
}

/// @nodoc
mixin _$ListingLocation {
  String get city => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;

  /// Serializes this ListingLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingLocationCopyWith<ListingLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingLocationCopyWith<$Res> {
  factory $ListingLocationCopyWith(
    ListingLocation value,
    $Res Function(ListingLocation) then,
  ) = _$ListingLocationCopyWithImpl<$Res, ListingLocation>;
  @useResult
  $Res call({String city, double lat, double lng});
}

/// @nodoc
class _$ListingLocationCopyWithImpl<$Res, $Val extends ListingLocation>
    implements $ListingLocationCopyWith<$Res> {
  _$ListingLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? city = null, Object? lat = null, Object? lng = null}) {
    return _then(
      _value.copyWith(
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ListingLocationImplCopyWith<$Res>
    implements $ListingLocationCopyWith<$Res> {
  factory _$$ListingLocationImplCopyWith(
    _$ListingLocationImpl value,
    $Res Function(_$ListingLocationImpl) then,
  ) = __$$ListingLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String city, double lat, double lng});
}

/// @nodoc
class __$$ListingLocationImplCopyWithImpl<$Res>
    extends _$ListingLocationCopyWithImpl<$Res, _$ListingLocationImpl>
    implements _$$ListingLocationImplCopyWith<$Res> {
  __$$ListingLocationImplCopyWithImpl(
    _$ListingLocationImpl _value,
    $Res Function(_$ListingLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListingLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? city = null, Object? lat = null, Object? lng = null}) {
    return _then(
      _$ListingLocationImpl(
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingLocationImpl implements _ListingLocation {
  const _$ListingLocationImpl({
    required this.city,
    required this.lat,
    required this.lng,
  });

  factory _$ListingLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingLocationImplFromJson(json);

  @override
  final String city;
  @override
  final double lat;
  @override
  final double lng;

  @override
  String toString() {
    return 'ListingLocation(city: $city, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingLocationImpl &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, city, lat, lng);

  /// Create a copy of ListingLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingLocationImplCopyWith<_$ListingLocationImpl> get copyWith =>
      __$$ListingLocationImplCopyWithImpl<_$ListingLocationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingLocationImplToJson(this);
  }
}

abstract class _ListingLocation implements ListingLocation {
  const factory _ListingLocation({
    required final String city,
    required final double lat,
    required final double lng,
  }) = _$ListingLocationImpl;

  factory _ListingLocation.fromJson(Map<String, dynamic> json) =
      _$ListingLocationImpl.fromJson;

  @override
  String get city;
  @override
  double get lat;
  @override
  double get lng;

  /// Create a copy of ListingLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingLocationImplCopyWith<_$ListingLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingBudget _$ListingBudgetFromJson(Map<String, dynamic> json) {
  return _ListingBudget.fromJson(json);
}

/// @nodoc
mixin _$ListingBudget {
  String get type => throw _privateConstructorUsedError; // 'fixed' or 'range'
  double get min => throw _privateConstructorUsedError;
  double get max => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this ListingBudget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingBudget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingBudgetCopyWith<ListingBudget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingBudgetCopyWith<$Res> {
  factory $ListingBudgetCopyWith(
    ListingBudget value,
    $Res Function(ListingBudget) then,
  ) = _$ListingBudgetCopyWithImpl<$Res, ListingBudget>;
  @useResult
  $Res call({String type, double min, double max, String currency});
}

/// @nodoc
class _$ListingBudgetCopyWithImpl<$Res, $Val extends ListingBudget>
    implements $ListingBudgetCopyWith<$Res> {
  _$ListingBudgetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingBudget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? min = null,
    Object? max = null,
    Object? currency = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            min: null == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as double,
            max: null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ListingBudgetImplCopyWith<$Res>
    implements $ListingBudgetCopyWith<$Res> {
  factory _$$ListingBudgetImplCopyWith(
    _$ListingBudgetImpl value,
    $Res Function(_$ListingBudgetImpl) then,
  ) = __$$ListingBudgetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, double min, double max, String currency});
}

/// @nodoc
class __$$ListingBudgetImplCopyWithImpl<$Res>
    extends _$ListingBudgetCopyWithImpl<$Res, _$ListingBudgetImpl>
    implements _$$ListingBudgetImplCopyWith<$Res> {
  __$$ListingBudgetImplCopyWithImpl(
    _$ListingBudgetImpl _value,
    $Res Function(_$ListingBudgetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListingBudget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? min = null,
    Object? max = null,
    Object? currency = null,
  }) {
    return _then(
      _$ListingBudgetImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        min: null == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as double,
        max: null == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingBudgetImpl implements _ListingBudget {
  const _$ListingBudgetImpl({
    required this.type,
    required this.min,
    required this.max,
    this.currency = 'TRY',
  });

  factory _$ListingBudgetImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingBudgetImplFromJson(json);

  @override
  final String type;
  // 'fixed' or 'range'
  @override
  final double min;
  @override
  final double max;
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'ListingBudget(type: $type, min: $min, max: $max, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingBudgetImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, min, max, currency);

  /// Create a copy of ListingBudget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingBudgetImplCopyWith<_$ListingBudgetImpl> get copyWith =>
      __$$ListingBudgetImplCopyWithImpl<_$ListingBudgetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingBudgetImplToJson(this);
  }
}

abstract class _ListingBudget implements ListingBudget {
  const factory _ListingBudget({
    required final String type,
    required final double min,
    required final double max,
    final String currency,
  }) = _$ListingBudgetImpl;

  factory _ListingBudget.fromJson(Map<String, dynamic> json) =
      _$ListingBudgetImpl.fromJson;

  @override
  String get type; // 'fixed' or 'range'
  @override
  double get min;
  @override
  double get max;
  @override
  String get currency;

  /// Create a copy of ListingBudget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingBudgetImplCopyWith<_$ListingBudgetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingDateRange _$ListingDateRangeFromJson(Map<String, dynamic> json) {
  return _ListingDateRange.fromJson(json);
}

/// @nodoc
mixin _$ListingDateRange {
  String get start => throw _privateConstructorUsedError;
  String get end => throw _privateConstructorUsedError;

  /// Serializes this ListingDateRange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingDateRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingDateRangeCopyWith<ListingDateRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingDateRangeCopyWith<$Res> {
  factory $ListingDateRangeCopyWith(
    ListingDateRange value,
    $Res Function(ListingDateRange) then,
  ) = _$ListingDateRangeCopyWithImpl<$Res, ListingDateRange>;
  @useResult
  $Res call({String start, String end});
}

/// @nodoc
class _$ListingDateRangeCopyWithImpl<$Res, $Val extends ListingDateRange>
    implements $ListingDateRangeCopyWith<$Res> {
  _$ListingDateRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingDateRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? start = null, Object? end = null}) {
    return _then(
      _value.copyWith(
            start: null == start
                ? _value.start
                : start // ignore: cast_nullable_to_non_nullable
                      as String,
            end: null == end
                ? _value.end
                : end // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ListingDateRangeImplCopyWith<$Res>
    implements $ListingDateRangeCopyWith<$Res> {
  factory _$$ListingDateRangeImplCopyWith(
    _$ListingDateRangeImpl value,
    $Res Function(_$ListingDateRangeImpl) then,
  ) = __$$ListingDateRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String start, String end});
}

/// @nodoc
class __$$ListingDateRangeImplCopyWithImpl<$Res>
    extends _$ListingDateRangeCopyWithImpl<$Res, _$ListingDateRangeImpl>
    implements _$$ListingDateRangeImplCopyWith<$Res> {
  __$$ListingDateRangeImplCopyWithImpl(
    _$ListingDateRangeImpl _value,
    $Res Function(_$ListingDateRangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListingDateRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? start = null, Object? end = null}) {
    return _then(
      _$ListingDateRangeImpl(
        start: null == start
            ? _value.start
            : start // ignore: cast_nullable_to_non_nullable
                  as String,
        end: null == end
            ? _value.end
            : end // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingDateRangeImpl implements _ListingDateRange {
  const _$ListingDateRangeImpl({required this.start, required this.end});

  factory _$ListingDateRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingDateRangeImplFromJson(json);

  @override
  final String start;
  @override
  final String end;

  @override
  String toString() {
    return 'ListingDateRange(start: $start, end: $end)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingDateRangeImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, start, end);

  /// Create a copy of ListingDateRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingDateRangeImplCopyWith<_$ListingDateRangeImpl> get copyWith =>
      __$$ListingDateRangeImplCopyWithImpl<_$ListingDateRangeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingDateRangeImplToJson(this);
  }
}

abstract class _ListingDateRange implements ListingDateRange {
  const factory _ListingDateRange({
    required final String start,
    required final String end,
  }) = _$ListingDateRangeImpl;

  factory _ListingDateRange.fromJson(Map<String, dynamic> json) =
      _$ListingDateRangeImpl.fromJson;

  @override
  String get start;
  @override
  String get end;

  /// Create a copy of ListingDateRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingDateRangeImplCopyWith<_$ListingDateRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingAttachment _$ListingAttachmentFromJson(Map<String, dynamic> json) {
  return _ListingAttachment.fromJson(json);
}

/// @nodoc
mixin _$ListingAttachment {
  String get url => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this ListingAttachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingAttachmentCopyWith<ListingAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingAttachmentCopyWith<$Res> {
  factory $ListingAttachmentCopyWith(
    ListingAttachment value,
    $Res Function(ListingAttachment) then,
  ) = _$ListingAttachmentCopyWithImpl<$Res, ListingAttachment>;
  @useResult
  $Res call({String url, String type});
}

/// @nodoc
class _$ListingAttachmentCopyWithImpl<$Res, $Val extends ListingAttachment>
    implements $ListingAttachmentCopyWith<$Res> {
  _$ListingAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? url = null, Object? type = null}) {
    return _then(
      _value.copyWith(
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ListingAttachmentImplCopyWith<$Res>
    implements $ListingAttachmentCopyWith<$Res> {
  factory _$$ListingAttachmentImplCopyWith(
    _$ListingAttachmentImpl value,
    $Res Function(_$ListingAttachmentImpl) then,
  ) = __$$ListingAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String type});
}

/// @nodoc
class __$$ListingAttachmentImplCopyWithImpl<$Res>
    extends _$ListingAttachmentCopyWithImpl<$Res, _$ListingAttachmentImpl>
    implements _$$ListingAttachmentImplCopyWith<$Res> {
  __$$ListingAttachmentImplCopyWithImpl(
    _$ListingAttachmentImpl _value,
    $Res Function(_$ListingAttachmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListingAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? url = null, Object? type = null}) {
    return _then(
      _$ListingAttachmentImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingAttachmentImpl implements _ListingAttachment {
  const _$ListingAttachmentImpl({required this.url, required this.type});

  factory _$ListingAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingAttachmentImplFromJson(json);

  @override
  final String url;
  @override
  final String type;

  @override
  String toString() {
    return 'ListingAttachment(url: $url, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingAttachmentImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, type);

  /// Create a copy of ListingAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingAttachmentImplCopyWith<_$ListingAttachmentImpl> get copyWith =>
      __$$ListingAttachmentImplCopyWithImpl<_$ListingAttachmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingAttachmentImplToJson(this);
  }
}

abstract class _ListingAttachment implements ListingAttachment {
  const factory _ListingAttachment({
    required final String url,
    required final String type,
  }) = _$ListingAttachmentImpl;

  factory _ListingAttachment.fromJson(Map<String, dynamic> json) =
      _$ListingAttachmentImpl.fromJson;

  @override
  String get url;
  @override
  String get type;

  /// Create a copy of ListingAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingAttachmentImplCopyWith<_$ListingAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingUser _$ListingUserFromJson(Map<String, dynamic> json) {
  return _ListingUser.fromJson(json);
}

/// @nodoc
mixin _$ListingUser {
  String get userId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;

  /// Serializes this ListingUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingUserCopyWith<ListingUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingUserCopyWith<$Res> {
  factory $ListingUserCopyWith(
    ListingUser value,
    $Res Function(ListingUser) then,
  ) = _$ListingUserCopyWithImpl<$Res, ListingUser>;
  @useResult
  $Res call({String userId, String? name, String? avatar});
}

/// @nodoc
class _$ListingUserCopyWithImpl<$Res, $Val extends ListingUser>
    implements $ListingUserCopyWith<$Res> {
  _$ListingUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = freezed,
    Object? avatar = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatar: freezed == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ListingUserImplCopyWith<$Res>
    implements $ListingUserCopyWith<$Res> {
  factory _$$ListingUserImplCopyWith(
    _$ListingUserImpl value,
    $Res Function(_$ListingUserImpl) then,
  ) = __$$ListingUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String? name, String? avatar});
}

/// @nodoc
class __$$ListingUserImplCopyWithImpl<$Res>
    extends _$ListingUserCopyWithImpl<$Res, _$ListingUserImpl>
    implements _$$ListingUserImplCopyWith<$Res> {
  __$$ListingUserImplCopyWithImpl(
    _$ListingUserImpl _value,
    $Res Function(_$ListingUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListingUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = freezed,
    Object? avatar = freezed,
  }) {
    return _then(
      _$ListingUserImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatar: freezed == avatar
            ? _value.avatar
            : avatar // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingUserImpl implements _ListingUser {
  const _$ListingUserImpl({required this.userId, this.name, this.avatar});

  factory _$ListingUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingUserImplFromJson(json);

  @override
  final String userId;
  @override
  final String? name;
  @override
  final String? avatar;

  @override
  String toString() {
    return 'ListingUser(userId: $userId, name: $name, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingUserImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, name, avatar);

  /// Create a copy of ListingUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingUserImplCopyWith<_$ListingUserImpl> get copyWith =>
      __$$ListingUserImplCopyWithImpl<_$ListingUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingUserImplToJson(this);
  }
}

abstract class _ListingUser implements ListingUser {
  const factory _ListingUser({
    required final String userId,
    final String? name,
    final String? avatar,
  }) = _$ListingUserImpl;

  factory _ListingUser.fromJson(Map<String, dynamic> json) =
      _$ListingUserImpl.fromJson;

  @override
  String get userId;
  @override
  String? get name;
  @override
  String? get avatar;

  /// Create a copy of ListingUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingUserImplCopyWith<_$ListingUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
