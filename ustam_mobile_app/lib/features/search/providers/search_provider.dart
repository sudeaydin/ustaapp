import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/error_handler.dart';

// Search providers
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.getCategories();
  
  if (response.isSuccess && response.data != null) {
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
  
  if (response.isSuccess && response.data != null) {
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
  final String selectedSortBy;
  final bool showFilters;

  const SearchState({
    this.craftsmen = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.selectedCategory = '',
    this.selectedCity = '',
    this.selectedSortBy = 'rating',
    this.showFilters = false,
  });

  SearchState copyWith({
    List<Map<String, dynamic>>? craftsmen,
    bool? isLoading,
    AppError? error,
    String? query,
    String? selectedCategory,
    String? selectedCity,
    String? selectedSortBy,
    bool? showFilters,
  }) {
    return SearchState(
      craftsmen: craftsmen ?? this.craftsmen,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedSortBy: selectedSortBy ?? this.selectedSortBy,
      showFilters: showFilters ?? this.showFilters,
    );
  }
}

// Search notifier
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState()) {
    // Auto-search on initialization
    searchCraftsmen();
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

  // Search craftsmen
  Future<void> searchCraftsmen() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.searchCraftsmen(
        query: state.query.isEmpty ? null : state.query,
        category: state.selectedCategory.isEmpty ? null : state.selectedCategory,
        city: state.selectedCity.isEmpty ? null : state.selectedCity,
        sortBy: state.selectedSortBy,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] && data['data'] != null) {
          state = state.copyWith(
            craftsmen: List<Map<String, dynamic>>.from(data['data']),
            isLoading: false,
            error: null,
          );
          return;
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: response.error ?? AppError(
          type: ErrorType.server,
          message: 'Arama sonuçları yüklenemedi',
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppError ? e : AppError.fromException(e),
      );
    }
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(
      query: '',
      selectedCategory: '',
      selectedCity: '',
      selectedSortBy: 'rating',
      showFilters: false,
    );
    searchCraftsmen();
  }

  // Retry search
  void retrySearch() {
    searchCraftsmen();
  }
}