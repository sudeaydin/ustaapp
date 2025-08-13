import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../models/marketplace_listing.dart';

class MarketplaceListingCard extends StatelessWidget {
  final MarketplaceListing listing;
  final String userType;
  final VoidCallback onTap;
  final VoidCallback? onOfferTap;

  const MarketplaceListingCard({
    super.key,
    required this.listing,
    required this.userType,
    required this.onTap,
    this.onOfferTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space16),
      child: AirbnbCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.gray900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DesignTokens.space4),
                      
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.space8,
                          vertical: DesignTokens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryCoral.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radius12),
                        ),
                        child: Text(
                          listing.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.primaryCoral,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status badge
                _buildStatusBadge(),
              ],
            ),
            
            const SizedBox(height: DesignTokens.space12),
            
            // Description
            Text(
              listing.description,
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.gray600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: DesignTokens.space16),
            
            // Location and budget row
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: DesignTokens.gray500,
                ),
                const SizedBox(width: DesignTokens.space4),
                Text(
                  listing.location.city,
                  style: const TextStyle(
                    fontSize: 13,
                    color: DesignTokens.gray600,
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: DesignTokens.gray500,
                ),
                Text(
                  _formatBudget(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.gray900,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: DesignTokens.space16),
            
            // Bottom row
            Row(
              children: [
                // Date posted
                Text(
                  _formatDate(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.gray500,
                  ),
                ),
                
                // Bids count
                if (listing.bidsCount > 0) ...[
                  const SizedBox(width: DesignTokens.space16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space8,
                      vertical: DesignTokens.space4,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radius12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 14,
                          color: DesignTokens.info,
                        ),
                        const SizedBox(width: DesignTokens.space4),
                        Text(
                          '${listing.bidsCount} teklif',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Action buttons
                if (userType == 'craftsman' && listing.status == 'open') ...[
                  AirbnbButton(
                    text: 'Teklif Ver',
                    onPressed: onOfferTap,
                    type: AirbnbButtonType.primary,
                    size: AirbnbButtonSize.small,
                  ),
                ] else ...[
                  AirbnbButton(
                    text: 'Detay',
                    onPressed: onTap,
                    type: AirbnbButtonType.outline,
                    size: AirbnbButtonSize.small,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (listing.status) {
      case 'open':
        backgroundColor = DesignTokens.success.withOpacity(0.1);
        textColor = DesignTokens.success;
        text = 'Açık';
        icon = Icons.radio_button_checked;
        break;
      case 'closed':
        backgroundColor = DesignTokens.gray400.withOpacity(0.1);
        textColor = DesignTokens.gray600;
        text = 'Kapalı';
        icon = Icons.radio_button_unchecked;
        break;
      default:
        backgroundColor = DesignTokens.warning.withOpacity(0.1);
        textColor = DesignTokens.warning;
        text = 'Beklemede';
        icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space8,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DesignTokens.radius12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: DesignTokens.space4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBudget() {
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    
    if (listing.budget.type == 'fixed') {
      return formatter.format(listing.budget.min);
    } else {
      return '${formatter.format(listing.budget.min)} - ${formatter.format(listing.budget.max)}';
    }
  }

  String _formatDate() {
    final now = DateTime.now();
    final difference = now.difference(listing.postedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }
}