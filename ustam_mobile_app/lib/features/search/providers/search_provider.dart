import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/error_handler.dart';
import '../models/search_filters.dart';

// Search providers
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.getCategories();
  
  if (response.success && response.data != null) {
    final data = response.data as Map<String, dynamic>;
    if (data['success'] && data['data'] != null) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
  }
  
  throw response.error ?? AppError(
    type: ErrorType.server,
    message: 'Kategoriler yüklenemedi',
  );
});

final locationsProvider = FutureProvider<List<String>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.getLocations();
  
  if (response.success && response.data != null) {
    final data = response.data as Map<String, dynamic>;
    if (data['success'] && data['data'] != null) {
      return List<String>.from(data['data']);
    }
  }
  
  throw response.error ?? AppError(
    type: ErrorType.server,
    message: 'Şehirler yüklenemedi',
  );
});

// Search state
class SearchState {
  final List<Map<String, dynamic>> craftsmen;
  final bool isLoading;
  final AppError? error;
  final String query;
  final String selectedCategory;
  final String selectedCity;
  final FilterOptions? filterOptions;
  final List<String> districts;
  final String selectedSortBy;
  final bool showFilters;
  final SearchFilters? currentFilters;

  const SearchState({
    this.craftsmen = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.selectedCategory = '',
    this.selectedCity = '',
    this.filterOptions,
    this.districts = const [],
    this.selectedSortBy = 'rating',
    this.showFilters = false,
    this.currentFilters,
  });

  SearchState copyWith({
    List<Map<String, dynamic>>? craftsmen,
    bool? isLoading,
    AppError? error,
    String? query,
    String? selectedCategory,
    String? selectedCity,
    FilterOptions? filterOptions,
    List<String>? districts,
    String? selectedSortBy,
    bool? showFilters,
    SearchFilters? currentFilters,
  }) {
    return SearchState(
      craftsmen: craftsmen ?? this.craftsmen,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCity: selectedCity ?? this.selectedCity,
      filterOptions: filterOptions ?? this.filterOptions,
      districts: districts ?? this.districts,
      selectedSortBy: selectedSortBy ?? this.selectedSortBy,
      showFilters: showFilters ?? this.showFilters,
      currentFilters: currentFilters ?? this.currentFilters,
    );
  }
}

// Search notifier
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState()) {
    // Don't auto-search to avoid immediate errors when backend is down
    // searchCraftsmen();
  }

  final ApiService _apiService = ApiService();

  // Update search query
  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  // Update filters
  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    searchCraftsmen();
  }

  void updateCity(String city) {
    state = state.copyWith(selectedCity: city);
    searchCraftsmen();
  }

  void updateSortBy(String sortBy) {
    state = state.copyWith(selectedSortBy: sortBy);
    searchCraftsmen();
  }

  void toggleFilters() {
    state = state.copyWith(showFilters: !state.showFilters);
  }

  // Basic search craftsmen (simplified)
  Future<void> searchCraftsmen() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParams = <String, String>{};
      if (state.query.isNotEmpty) queryParams['q'] = state.query;
      if (state.selectedCategory.isNotEmpty) queryParams['category'] = state.selectedCategory;
      if (state.selectedCity.isNotEmpty) queryParams['city'] = state.selectedCity;
      queryParams['sort_by'] = state.selectedSortBy;
      
      final apiResponse = await ApiService.getInstance().get(
        '/search/craftsmen',
        queryParams: queryParams,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        print('🔍 Search API Response: ${apiResponse.data}');
        
        // Fix: API response has nested structure: {data: {craftsmen: [...]}}
        final responseData = apiResponse.data!['data'] as Map<String, dynamic>? ?? {};
        final craftsmen = List<Map<String, dynamic>>.from(
          responseData['craftsmen'] ?? []
        );
        print('🔍 Parsed craftsmen count: ${craftsmen.length}');

        state = state.copyWith(
          craftsmen: craftsmen,
          isLoading: false,
        );
      } else {
        print('❌ Search API Failed: ${apiResponse.error}');
        state = state.copyWith(
          error: AppError(
            type: ErrorType.server,
            message: 'Arama yapılamadı',
          ),
          isLoading: false,
        );
      }
    } catch (e) {
      String errorMessage = 'Ağ bağlantısı hatası';
      ErrorType errorType = ErrorType.network;
      
      // Provide more specific error messages
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Failed host lookup')) {
        errorMessage = 'Backend sunucusu çalışmıyor. Lütfen sunucuyu başlatın.';
        errorType = ErrorType.server;
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'İstek zaman aşımına uğradı';
        errorType = ErrorType.timeout;
      }
      
      state = state.copyWith(
        error: AppError(
          type: errorType,
          message: errorMessage,
        ),
        isLoading: false,
      );
    }
  }

  // Remove advanced search - just use basic search
  Future<void> searchCraftsmenWithFilters(SearchFilters filters) async {
    // Update basic search parameters
    state = state.copyWith(
      query: filters.query ?? '',
      selectedCategory: filters.category ?? '',
      selectedCity: filters.city ?? '',
      selectedSortBy: filters.sortBy,
    );
    
    // Use basic search
    await searchCraftsmen();
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(
      query: '',
      selectedCategory: '',
      selectedCity: '',
      selectedSortBy: 'rating',
      showFilters: false,
      currentFilters: null,
    );
    searchCraftsmen();
  }

  // Retry search
  void retrySearch() {
    if (state.currentFilters != null) {
      searchCraftsmenWithFilters(state.currentFilters!);
    } else {
      searchCraftsmen();
    }
  }

  Future<void> loadFilterOptions() async {
    try {
      final apiResponse = await ApiService.getInstance().get('/search/filters');

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final filterOptions = FilterOptions.fromJson(apiResponse.data!);
        state = state.copyWith(filterOptions: filterOptions);
      }
    } catch (e) {
      // Filter options are optional, don't show error
    }
  }

  Future<void> loadDistricts(String city) async {
    try {
      final apiResponse = await ApiService.getInstance().get(
        '/search/districts',
        queryParams: {'city': city},
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final districts = List<String>.from(apiResponse.data! ?? []);
        state = state.copyWith(districts: districts);
      }
    } catch (e) {
      // Districts are optional, don't show error
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Update filters
  void updateFilters(SearchFilters filters) {
    state = state.copyWith(
      query: filters.query ?? '',
      selectedCategory: filters.category ?? '',
      selectedCity: filters.city ?? '',
      // Store filters for advanced search
      currentFilters: filters,
    );
  }
}