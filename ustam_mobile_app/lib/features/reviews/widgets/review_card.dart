import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/review_model.dart';
import 'star_rating.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool showCustomerInfo;
  final VoidCallback? onTap;

  const ReviewCard({
    super.key,
    required this.review,
    this.showCustomerInfo = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with customer info and rating
              Row(
                children: [
                  if (showCustomerInfo && review.customer != null) ...[
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: review.customer!.user.profileImage != null
                          ? NetworkImage(review.customer!.user.profileImage!)
                          : null,
                      child: review.customer!.user.profileImage == null
                          ? Text(
                              review.customer!.user.firstName[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.customer!.user.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatDate(review.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  StarRating(
                    rating: review.rating.toDouble(),
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title if exists
              if (review.title != null) ...[
                Text(
                  review.title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Comment
              if (review.comment != null)
                Text(
                  review.comment!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

              // Category ratings
              if (review.qualityRating != null || 
                  review.punctualityRating != null || 
                  review.communicationRating != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (review.communicationRating != null)
                      CategoryRatingDisplay(
                        title: 'İletişim',
                        rating: review.communicationRating!.toDouble(),
                        icon: Icons.chat_bubble_outline,
                        color: AppColors.primary,
                      ),
                    if (review.qualityRating != null)
                      CategoryRatingDisplay(
                        title: 'Kalite',
                        rating: review.qualityRating!.toDouble(),
                        icon: Icons.star_outline,
                        color: AppColors.uclaBlue,
                      ),
                    if (review.punctualityRating != null)
                      CategoryRatingDisplay(
                        title: 'Hız',
                        rating: review.punctualityRating!.toDouble(),
                        icon: Icons.speed,
                        color: AppColors.mintGreen,
                      ),
                  ],
                ),
              ],

              // Service info if available
              if (review.service != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    review.service!.title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              // Verified badge
              if (review.isVerified) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Doğrulanmış Alım',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Craftsman response if exists
              if (review.craftsmanResponse != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Usta Yanıtı',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          if (review.responseDate != null)
                            Text(
                              _formatDate(review.responseDate!),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.craftsmanResponse!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasDetailedRatings() {
    return review.qualityRating != null ||
        review.punctualityRating != null ||
        review.communicationRating != null ||
        review.cleanlinessRating != null;
  }

  Widget _buildDetailedRatings() {
    return Column(
      children: [
        if (review.qualityRating != null)
          _buildRatingRow('Kalite', review.qualityRating!),
        if (review.punctualityRating != null)
          _buildRatingRow('Dakiklik', review.punctualityRating!),
        if (review.communicationRating != null)
          _buildRatingRow('İletişim', review.communicationRating!),
        if (review.cleanlinessRating != null)
          _buildRatingRow('Temizlik', review.cleanlinessRating!),
      ],
    );
  }

  Widget _buildRatingRow(String label, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          StarRating(
            rating: rating.toDouble(),
            size: 14,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    }
  }
}