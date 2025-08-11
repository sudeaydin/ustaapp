import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/review_model.dart';

class ReviewState {
  final List<Review> reviews;
  final ReviewStatistics? statistics;
  final bool isLoading;
  final String? error;

  ReviewState({
    this.reviews = const [],
    this.statistics,
    this.isLoading = false,
    this.error,
  });

  ReviewState copyWith({
    List<Review>? reviews,
    ReviewStatistics? statistics,
    bool? isLoading,
    String? error,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  ReviewNotifier() : super(ReviewState());

  Future<void> loadCraftsmanReviews(int craftsmanId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiResponse = await ApiService.getInstance().get(
        '/reviews',
        queryParams: {'craftsman_id': craftsmanId.toString()},
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final reviews = List<Review>.from(
          apiResponse.data!['reviews']?.map((json) => Review.fromJson(json)) ?? []
        );

        state = state.copyWith(
          reviews: reviews,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Değerlendirmeler getirilemedi',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Değerlendirmeler yüklenirken hata oluştu',
        isLoading: false,
      );
    }
  }

  Future<void> loadReviewStatistics(int craftsmanId) async {
    try {
      final apiResponse = await ApiService.getInstance().get(
        '/reviews/statistics/$craftsmanId',
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final statistics = ReviewStatistics.fromJson(apiResponse.data!);
        state = state.copyWith(statistics: statistics);
      }
    } catch (e) {
      // Statistics are optional, don't show error
    }
  }

  Future<bool> createReview({
    required int craftsmanId,
    required int quoteId,
    required int rating,
    required String comment,
    String? title,
    int? qualityRating,
    int? punctualityRating,
    int? communicationRating,
    int? cleanlinessRating,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiResponse = await ApiService.getInstance().post('/reviews', {
        'craftsman_id': craftsmanId,
        'quote_id': quoteId,
        'rating': rating,
        'comment': comment,
        'title': title,
        'quality_rating': qualityRating,
        'punctuality_rating': punctualityRating,
        'communication_rating': communicationRating,
        'cleanliness_rating': cleanlinessRating,
      });

      if (apiResponse.isSuccess) {
        // Reload reviews
        await loadCraftsmanReviews(craftsmanId);
        return true;
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Değerlendirme oluşturulamadı',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Değerlendirme gönderilirken hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
    String? title,
    int? qualityRating,
    int? punctualityRating,
    int? communicationRating,
    int? cleanlinessRating,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updateData = <String, dynamic>{};
      if (rating != null) updateData['rating'] = rating;
      if (comment != null) updateData['comment'] = comment;
      if (title != null) updateData['title'] = title;
      if (qualityRating != null) updateData['quality_rating'] = qualityRating;
      if (punctualityRating != null) updateData['punctuality_rating'] = punctualityRating;
      if (communicationRating != null) updateData['communication_rating'] = communicationRating;
      if (cleanlinessRating != null) updateData['cleanliness_rating'] = cleanlinessRating;

      final apiResponse = await ApiService.getInstance().put('/reviews/$reviewId', updateData);

      if (apiResponse.isSuccess) {
        // Find and update the review in current state
        final updatedReviews = state.reviews.map((review) {
          if (review.id == reviewId) {
            return Review.fromJson(apiResponse.data!['review']);
          }
          return review;
        }).toList();

        state = state.copyWith(
          reviews: updatedReviews,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Değerlendirme güncellenemedi',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Değerlendirme güncellenirken hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>((ref) {
  return ReviewNotifier();
});