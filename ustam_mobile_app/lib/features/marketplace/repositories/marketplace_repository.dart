import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/marketplace_listing.dart';
import '../models/marketplace_offer.dart';
import '../../../core/config/app_config.dart';

class MarketplaceRepository {
  final http.Client _client;
  
  MarketplaceRepository({http.Client? client}) : _client = client ?? http.Client();

  // Get marketplace listings with filters
  Future<MarketplaceListingsResponse> getListings({
    String? query,
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (query != null) queryParams['query'] = query;
    if (category != null) queryParams['category'] = category;
    if (location != null) queryParams['location'] = location;
    if (minBudget != null) queryParams['minBudget'] = minBudget.toString();
    if (maxBudget != null) queryParams['maxBudget'] = maxBudget.toString();

    final uri = Uri.parse('${AppConfig.apiUrl}/marketplace/listings')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MarketplaceListingsResponse.fromJson(data);
    } else {
      throw Exception('Failed to load listings: ${response.statusCode}');
    }
  }

  // Get single listing with offers
  Future<MarketplaceListingDetail> getListingDetail(String id) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiUrl}/marketplace/listings/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MarketplaceListingDetail.fromJson(data);
    } else {
      throw Exception('Failed to load listing detail: ${response.statusCode}');
    }
  }

  // Create new listing
  Future<MarketplaceListing> createListing(CreateListingRequest request) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiUrl}/marketplace/listings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return MarketplaceListing.fromJson(data);
    } else {
      throw Exception('Failed to create listing: ${response.statusCode}');
    }
  }

  // Update listing
  Future<MarketplaceListing> updateListing(String id, UpdateListingRequest request) async {
    final response = await _client.patch(
      Uri.parse('${AppConfig.apiUrl}/marketplace/listings/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MarketplaceListing.fromJson(data);
    } else {
      throw Exception('Failed to update listing: ${response.statusCode}');
    }
  }

  // Submit offer to listing
  Future<MarketplaceOffer> submitOffer(String listingId, SubmitOfferRequest request) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiUrl}/marketplace/listings/$listingId/offers'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return MarketplaceOffer.fromJson(data);
    } else {
      throw Exception('Failed to submit offer: ${response.statusCode}');
    }
  }

  // Get user's listings
  Future<List<MarketplaceListing>> getUserListings(String userId) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiUrl}/marketplace/my-listings'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['listings'] as List)
          .map((item) => MarketplaceListing.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load user listings: ${response.statusCode}');
    }
  }

  // Get craftsman's offers
  Future<List<MarketplaceOffer>> getCraftsmanOffers(String craftsmanId) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiUrl}/marketplace/my-offers'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['offers'] as List)
          .map((item) => MarketplaceOffer.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load craftsman offers: ${response.statusCode}');
    }
  }
}

// Response models
class MarketplaceListingsResponse {
  final List<MarketplaceListing> listings;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  MarketplaceListingsResponse({
    required this.listings,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory MarketplaceListingsResponse.fromJson(Map<String, dynamic> json) {
    return MarketplaceListingsResponse(
      listings: (json['listings'] as List)
          .map((item) => MarketplaceListing.fromJson(item))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class MarketplaceListingDetail {
  final MarketplaceListing listing;
  final List<MarketplaceOffer> offers;

  MarketplaceListingDetail({
    required this.listing,
    required this.offers,
  });

  factory MarketplaceListingDetail.fromJson(Map<String, dynamic> json) {
    return MarketplaceListingDetail(
      listing: MarketplaceListing.fromJson(json['listing']),
      offers: (json['offers'] as List? ?? [])
          .map((item) => MarketplaceOffer.fromJson(item))
          .toList(),
    );
  }
}

// Request models
class CreateListingRequest {
  final String title;
  final String description;
  final String category;
  final ListingLocation location;
  final ListingBudget budget;
  final ListingDateRange dateRange;
  final List<ListingAttachment> attachments;

  CreateListingRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.budget,
    required this.dateRange,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location.toJson(),
      'budget': budget.toJson(),
      'dateRange': dateRange.toJson(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'visibility': 'marketplace',
    };
  }
}

class UpdateListingRequest {
  final String? title;
  final String? description;
  final String? status;
  final ListingBudget? budget;
  final ListingDateRange? dateRange;

  UpdateListingRequest({
    this.title,
    this.description,
    this.status,
    this.budget,
    this.dateRange,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;
    if (budget != null) data['budget'] = budget!.toJson();
    if (dateRange != null) data['dateRange'] = dateRange!.toJson();
    return data;
  }
}

class SubmitOfferRequest {
  final double amount;
  final String? note;
  final int etaDays;

  SubmitOfferRequest({
    required this.amount,
    this.note,
    required this.etaDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'note': note,
      'etaDays': etaDays,
      'currency': 'TRY',
    };
  }
}