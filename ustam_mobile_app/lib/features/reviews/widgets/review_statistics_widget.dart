import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../models/review_model.dart';
import 'star_rating.dart';

class ReviewStatisticsWidget extends StatelessWidget {
  final ReviewStatistics statistics;

  const ReviewStatisticsWidget({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall rating summary
        _buildOverallRating(),
        
        const SizedBox(height: DesignTokens.space24),
        
        // Rating distribution
        _buildRatingDistribution(),
        
        const SizedBox(height: DesignTokens.space24),
        
        // Quick stats
        _buildQuickStats(),
      ],
    );
  }

  Widget _buildOverallRating() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignTokens.primaryCoral.withOpacity(0.1),
            DesignTokens.primaryCoral.withOpacity(0.1),
          ],
        ),
        borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
        border: Border.all(
          color: DesignTokens.primaryCoral.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Large rating number
          Column(
            children: [
              Text(
                statistics.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.primaryCoral,
                ),
              ),
              StarRating(
                rating: statistics.averageRating,
                size: 24,
              ),
            ],
          ),
          
          const SizedBox(width: 24),
          
          // Summary info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Genel Değerlendirme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${statistics.totalReviews} değerlendirme',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRatingDescription(statistics.averageRating),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.primaryCoral,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Puan Dağılımı',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        
        ...List.generate(5, (index) {
          final starCount = 5 - index;
          final count = statistics.ratingDistribution[starCount] ?? 0;
          final percentage = statistics.totalReviews > 0 
              ? (count / statistics.totalReviews) * 100 
              : 0.0;
          
          return _buildRatingBar(starCount, count, percentage);
        }),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Star count
          SizedBox(
            width: 20,
            child: Text(
              '$stars',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Star icon
          const Icon(
            Icons.star,
            size: 16,
            color: Colors.amber,
          ),
          
          const SizedBox(width: 12),
          
          // Progress bar
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const Borderconst Radius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryCoral,
                    borderRadius: const Borderconst Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Count and percentage
          SizedBox(
            width: 60,
            child: Text(
              '$count (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final highRatings = (statistics.ratingDistribution[4] ?? 0) + 
                      (statistics.ratingDistribution[5] ?? 0);
    final lowRatings = (statistics.ratingDistribution[1] ?? 0) + 
                     (statistics.ratingDistribution[2] ?? 0);
    
    final recommendationRate = statistics.totalReviews > 0 
        ? (highRatings / statistics.totalReviews) * 100 
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı İstatistikler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Toplam\nDeğerlendirme',
                statistics.totalReviews.toString(),
                Icons.rate_review,
                DesignTokens.primaryCoral,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Tavsiye\nOranı',
                '${recommendationRate.toStringAsFixed(0)}%',
                Icons.thumb_up,
                DesignTokens.primaryCoral,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Yüksek Puan\n(4-5 ⭐)',
                highRatings.toString(),
                Icons.trending_up,
                DesignTokens.primaryCoral,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Düşük Puan\n(1-2 ⭐)',
                lowRatings.toString(),
                Icons.trending_down,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getRatingDescription(double rating) {
    if (rating >= 4.5) {
      return 'Mükemmel';
    } else if (rating >= 4.0) {
      return 'Çok İyi';
    } else if (rating >= 3.5) {
      return 'İyi';
    } else if (rating >= 3.0) {
      return 'Orta';
    } else if (rating >= 2.0) {
      return 'Kötü';
    } else {
      return 'Çok Kötü';
    }
  }
}