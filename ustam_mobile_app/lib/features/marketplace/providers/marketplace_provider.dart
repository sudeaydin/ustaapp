import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/marketplace_listing.dart';
import '../models/marketplace_offer.dart';
import '../repositories/marketplace_repository.dart';

// Repository provider
final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository();
});

// Marketplace feed state
class MarketplaceFeedState {
  final List<MarketplaceListing> listings;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? searchQuery;
  final String? selectedCategory;
  final String? selectedLocation;
  final double? minBudget;
  final double? maxBudget;

  MarketplaceFeedState({
    this.listings = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery,
    this.selectedCategory,
    this.selectedLocation,
    this.minBudget,
    this.maxBudget,
  });

  MarketplaceFeedState copyWith({
    List<MarketplaceListing>? listings,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    String? selectedCategory,
    String? selectedLocation,
    double? minBudget,
    double? maxBudget,
  }) {
    return MarketplaceFeedState(
      listings: listings ?? this.listings,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
    );
  }
}

// Marketplace feed notifier
class MarketplaceFeedNotifier extends StateNotifier<MarketplaceFeedState> {
  final MarketplaceRepository _repository;

  MarketplaceFeedNotifier(this._repository) : super(MarketplaceFeedState());

  Future<void> loadListings({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        error: null,
      );
    } else if (state.isLoadingMore || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final response = await _repository.getListings(
        query: state.searchQuery,
        category: state.selectedCategory,
        location: state.selectedLocation,
        minBudget: state.minBudget,
        maxBudget: state.maxBudget,
        page: refresh ? 1 : state.currentPage,
      );

      final newListings = refresh 
          ? response.listings
          : [...state.listings, ...response.listings];

      state = state.copyWith(
        listings: newListings,
        isLoading: false,
        isLoadingMore: false,
        currentPage: response.currentPage + 1,
        hasMore: response.currentPage < response.totalPages,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void updateFilters({
    String? searchQuery,
    String? selectedCategory,
    String? selectedLocation,
    double? minBudget,
    double? maxBudget,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      selectedCategory: selectedCategory,
      selectedLocation: selectedLocation,
      minBudget: minBudget,
      maxBudget: maxBudget,
    );
    loadListings(refresh: true);
  }

  void clearFilters() {
    state = MarketplaceFeedState();
    loadListings(refresh: true);
  }
}

// Feed provider
final marketplaceFeedProvider = StateNotifierProvider<MarketplaceFeedNotifier, MarketplaceFeedState>((ref) {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return MarketplaceFeedNotifier(repository);
});

// Listing detail provider
final listingDetailProvider = FutureProvider.family<MarketplaceListingDetail, String>((ref, listingId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getListingDetail(listingId);
});

// User listings provider
final userListingsProvider = FutureProvider.family<List<MarketplaceListing>, String>((ref, userId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getUserListings(userId);
});

// Craftsman offers provider
final craftsmanOffersProvider = FutureProvider.family<List<MarketplaceOffer>, String>((ref, craftsmanId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getCraftsmanOffers(craftsmanId);
});

// Create listing state
class CreateListingState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  CreateListingState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  CreateListingState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return CreateListingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class CreateListingNotifier extends StateNotifier<CreateListingState> {
  final MarketplaceRepository _repository;

  CreateListingNotifier(this._repository) : super(CreateListingState());

  Future<String?> createListing(CreateListingRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final listing = await _repository.createListing(request);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'İlan başarıyla oluşturuldu!',
      );
      return listing.id;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void clearState() {
    state = CreateListingState();
  }
}

final createListingProvider = StateNotifierProvider<CreateListingNotifier, CreateListingState>((ref) {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return CreateListingNotifier(repository);
});

// Submit offer state
class SubmitOfferState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  SubmitOfferState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  SubmitOfferState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return SubmitOfferState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class SubmitOfferNotifier extends StateNotifier<SubmitOfferState> {
  final MarketplaceRepository _repository;

  SubmitOfferNotifier(this._repository) : super(SubmitOfferState());

  Future<bool> submitOffer(String listingId, SubmitOfferRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.submitOffer(listingId, request);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Teklifiniz başarıyla gönderildi!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearState() {
    state = SubmitOfferState();
  }
}

final submitOfferProvider = StateNotifierProvider<SubmitOfferNotifier, SubmitOfferState>((ref) {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return SubmitOfferNotifier(repository);
});