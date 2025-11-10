import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/ios_icons.dart';
import '../../../core/widgets/airbnb_card.dart';
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
      margin: const EdgeInsets.only(bottom: DesignTokens.space16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Header row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: DesignTokens.primaryCoral.withOpacity(0.1),
                    backgroundImage: craftsman['avatar'] != null
                        ? NetworkImage(craftsman['avatar'])
                        : null,
                    child: craftsman['avatar'] == null
                        ? Text(
                            _getInitials(craftsman['name']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: DesignTokens.primaryCoral,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  
                  const SizedBox(width: DesignTokens.space16),
                  
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
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (craftsman['is_verified'] == true)
                              Icon(
                                iOSIcons.verified,
                                size: 20,
                                color: DesignTokens.primaryCoral,
                              ),
                          ],
                        ),
                        
                        if (craftsman['business_name'] != null) ...[
 SizedBox(height: 4),
                          Text(
                            craftsman['business_name'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        
 SizedBox(height: 8),
                        
                        // Rating and reviews
                        Row(
                          children: [
                            StarRating(
                              rating: (craftsman['average_rating'] ?? 0).toDouble(),
                              size: 16,
                            ),
 SizedBox(width: 8),
                            Text(
                              '${craftsman['average_rating']?.toStringAsFixed(1) ?? '0.0'}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
 SizedBox(width: 4),
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
              
              const SizedBox(height: DesignTokens.space16),
              
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
                        color: DesignTokens.primaryCoral.withOpacity(0.1),
                        borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
                      ),
                      child: Text(
                        skill.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.primaryCoral,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: DesignTokens.space16),
              
              // Bottom row
              Row(
                children: [
                  // Location
                  Icon(
                    iOSIcons.locationOn,
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
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryCoral.withOpacity(0.1),
                        borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
                      ),
                      child: Text(
                        '₺${craftsman['hourly_rate']}/saat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.primaryCoral,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Action buttons
              if (showReviewButton) ...[
 SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showReviews(context),
                        icon: Icon(iOSIcons.rateReview, size: 16),
                        label: Text('Değerlendirmeler'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DesignTokens.primaryCoral,
                          side: BorderSide(color: DesignTokens.primaryCoral.withOpacity(0.5)),
                        ),
                      ),
                    ),
 SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _requestQuote(context),
                        icon: Icon(Icons.request_quote, size: 16),
                        label: Text('Teklif Al'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.primaryCoral,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Availability indicator
              if (craftsman['is_available'] == false) ...[
 SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.red[600],
                      ),
 SizedBox(width: 4),
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