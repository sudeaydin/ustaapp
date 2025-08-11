class SearchFilters {
  final String? query;
  final String? category;
  final String? city;
  final String? district;
  final double? minRating;
  final double? maxRating;
  final double? minPrice;
  final double? maxPrice;
  final bool? isVerified;
  final bool? hasPortfolio;
  final String sortBy;
  final String sortOrder;

  SearchFilters({
    this.query,
    this.category,
    this.city,
    this.district,
    this.minRating,
    this.maxRating,
    this.minPrice,
    this.maxPrice,
    this.isVerified,
    this.hasPortfolio,
    this.sortBy = 'rating',
    this.sortOrder = 'desc',
  });

  SearchFilters copyWith({
    String? query,
    String? category,
    String? city,
    String? district,
    double? minRating,
    double? maxRating,
    double? minPrice,
    double? maxPrice,
    bool? isVerified,
    bool? hasPortfolio,
    String? sortBy,
    String? sortOrder,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      category: category ?? this.category,
      city: city ?? this.city,
      district: district ?? this.district,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isVerified: isVerified ?? this.isVerified,
      hasPortfolio: hasPortfolio ?? this.hasPortfolio,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (query != null && query!.isNotEmpty) params['q'] = query;
    if (category != null && category!.isNotEmpty) params['category'] = category;
    if (city != null && city!.isNotEmpty) params['city'] = city;
    if (district != null && district!.isNotEmpty) params['district'] = district;
    if (minRating != null) params['min_rating'] = minRating.toString();
    if (maxRating != null) params['max_rating'] = maxRating.toString();
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (isVerified != null) params['is_verified'] = isVerified.toString();
    if (hasPortfolio != null) params['has_portfolio'] = hasPortfolio.toString();
    params['sort_by'] = sortBy;
    params['sort_order'] = sortOrder;
    
    return params;
  }

  bool get hasActiveFilters {
    return query != null ||
        category != null ||
        city != null ||
        district != null ||
        minRating != null ||
        maxRating != null ||
        minPrice != null ||
        maxPrice != null ||
        isVerified != null ||
        hasPortfolio != null ||
        sortBy != 'rating' ||
        sortOrder != 'desc';
  }

  int get activeFilterCount {
    int count = 0;
    if (query != null && query!.isNotEmpty) count++;
    if (category != null && category!.isNotEmpty) count++;
    if (city != null && city!.isNotEmpty) count++;
    if (district != null && district!.isNotEmpty) count++;
    if (minRating != null || maxRating != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (isVerified != null) count++;
    if (hasPortfolio != null) count++;
    if (sortBy != 'rating' || sortOrder != 'desc') count++;
    return count;
  }

  SearchFilters clear() {
    return SearchFilters();
  }
}

class FilterOptions {
  final PriceRange priceRange;
  final RatingRange ratingRange;
  final VerificationStats verificationStats;
  final PortfolioStats portfolioStats;
  final List<SortOption> sortOptions;
  final List<SortOrder> sortOrders;

  FilterOptions({
    required this.priceRange,
    required this.ratingRange,
    required this.verificationStats,
    required this.portfolioStats,
    required this.sortOptions,
    required this.sortOrders,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      priceRange: PriceRange.fromJson(json['price_range']),
      ratingRange: RatingRange.fromJson(json['rating_range']),
      verificationStats: VerificationStats.fromJson(json['verification_stats']),
      portfolioStats: PortfolioStats.fromJson(json['portfolio_stats']),
      sortOptions: List<SortOption>.from(
        json['sort_options'].map((x) => SortOption.fromJson(x))
      ),
      sortOrders: List<SortOrder>.from(
        json['sort_orders'].map((x) => SortOrder.fromJson(x))
      ),
    );
  }
}

class PriceRange {
  final double min;
  final double max;
  final double avg;

  PriceRange({
    required this.min,
    required this.max,
    required this.avg,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      avg: (json['avg'] as num).toDouble(),
    );
  }
}

class RatingRange {
  final double min;
  final double max;
  final double avg;

  RatingRange({
    required this.min,
    required this.max,
    required this.avg,
  });

  factory RatingRange.fromJson(Map<String, dynamic> json) {
    return RatingRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      avg: (json['avg'] as num).toDouble(),
    );
  }
}

class VerificationStats {
  final int verifiedCount;
  final int totalCount;
  final double verificationRate;

  VerificationStats({
    required this.verifiedCount,
    required this.totalCount,
    required this.verificationRate,
  });

  factory VerificationStats.fromJson(Map<String, dynamic> json) {
    return VerificationStats(
      verifiedCount: json['verified_count'],
      totalCount: json['total_count'],
      verificationRate: (json['verification_rate'] as num).toDouble(),
    );
  }
}

class PortfolioStats {
  final int withPortfolio;
  final int withoutPortfolio;
  final double portfolioRate;

  PortfolioStats({
    required this.withPortfolio,
    required this.withoutPortfolio,
    required this.portfolioRate,
  });

  factory PortfolioStats.fromJson(Map<String, dynamic> json) {
    return PortfolioStats(
      withPortfolio: json['with_portfolio'],
      withoutPortfolio: json['without_portfolio'],
      portfolioRate: (json['portfolio_rate'] as num).toDouble(),
    );
  }
}

class SortOption {
  final String value;
  final String label;

  SortOption({
    required this.value,
    required this.label,
  });

  factory SortOption.fromJson(Map<String, dynamic> json) {
    return SortOption(
      value: json['value'],
      label: json['label'],
    );
  }
}

class SortOrder {
  final String value;
  final String label;

  SortOrder({
    required this.value,
    required this.label,
  });

  factory SortOrder.fromJson(Map<String, dynamic> json) {
    return SortOrder(
      value: json['value'],
      label: json['label'],
    );
  }
}