import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/hover_button.dart';
import '../../reviews/widgets/star_rating.dart';

class CraftsmanCard extends StatelessWidget {
  final Map<String, dynamic> craftsman;
  final VoidCallback? onTap;
  final bool showDistance;
  final bool showReviewButton;

  const CraftsmanCard({
    super.key,
    required this.craftsman,
    this.onTap,
    this.showDistance = false,
    this.showReviewButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AirbnbCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.cardPaddingInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: craftsman['avatar'] != null
                        ? NetworkImage(craftsman['avatar'])
                        : null,
                    child: craftsman['avatar'] == null
                        ? Text(
                            _getInitials(craftsman['name']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Name and business info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                craftsman['name'] ?? 'İsimsiz Usta',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (craftsman['is_verified'] == true)
                              Icon(
                                Icons.verified,
                                size: 20,
                                color: Colors.green[600],
                              ),
                          ],
                        ),
                        
                        if (craftsman['business_name'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            craftsman['business_name'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 8),
                        
                        // Rating and reviews
                        Row(
                          children: [
                            StarRating(
                              rating: (craftsman['average_rating'] ?? 0).toDouble(),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${craftsman['average_rating']?.toStringAsFixed(1) ?? '0.0'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${craftsman['total_reviews'] ?? 0} değerlendirme)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              if (craftsman['description'] != null)
                Text(
                  craftsman['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 12),
              
              // Skills/Specialties
              if (craftsman['specialties'] != null && craftsman['specialties'].isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (craftsman['specialties'] as List).take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        skill.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 16),
              
              // Bottom row
              Row(
                children: [
                  // Location
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${craftsman['district'] ?? ''} ${craftsman['city'] ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  
                  // Price
                  if (craftsman['hourly_rate'] != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₺${craftsman['hourly_rate']}/saat',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Action buttons
              if (showReviewButton) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showReviews(context),
                        icon: const Icon(Icons.rate_review, size: 16),
                        label: const Text('Değerlendirmeler'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _requestQuote(context),
                        icon: const Icon(Icons.request_quote, size: 16),
                        label: const Text('Teklif Al'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Availability indicator
              if (craftsman['is_available'] == false) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.red[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Şu anda müsait değil',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
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

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _showReviews(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/reviews',
      arguments: {
        'craftsmanId': craftsman['id'],
        'craftsmanName': craftsman['name'],
      },
    );
  }

  void _requestQuote(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/request-quote',
      arguments: {
        'craftsmanId': craftsman['id'],
        'craftsmanName': craftsman['name'],
      },
    );
  }
}