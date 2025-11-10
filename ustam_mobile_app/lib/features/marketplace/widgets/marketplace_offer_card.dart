import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../models/marketplace_offer.dart';

class MarketplaceOfferCard extends StatelessWidget {
  final MarketplaceOffer offer;
  final bool showActions;
  final bool isOwner;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onWithdraw;
  final VoidCallback? onTap;

  const MarketplaceOfferCard({
    super.key,
    required this.offer,
    this.showActions = false,
    this.isOwner = false,
    this.onAccept,
    this.onReject,
    this.onWithdraw,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AirbnbCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with provider info and status
          Row(
            children: [
              // Provider avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: DesignTokens.primaryCoral.withOpacity(0.1),
                backgroundImage: offer.provider?.avatar != null
                    ? NetworkImage(offer.provider!.avatar!)
                    : null,
                child: offer.provider?.avatar == null
                    ? Text(
                        offer.provider?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.primaryCoral,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: DesignTokens.space12),
              
              // Provider info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.provider?.name ?? 'Anonim Usta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (offer.provider != null) ...[
                      Row(
                        children: [
                          // Rating
                          if (offer.provider!.rating > 0) ...[
                            Icon(
                              Icons.star,
                              size: 14,
                              color: DesignTokens.warning,
                            ),
 SizedBox(width: 2),
                            Text(
                              offer.provider!.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: DesignTokens.gray700,
                              ),
                            ),
 SizedBox(width: 4),
                            Text(
                              '(${offer.provider!.reviewCount})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: DesignTokens.gray600,
                              ),
                            ),
                          ],
                          
                          // Speciality
                          if (offer.provider!.speciality != null) ...[
                            if (offer.provider!.rating > 0) 
 SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: DesignTokens.info.withOpacity(0.1),
                                borderRadius: const Borderconst Radius.circular(8),
                              ),
                              child: Text(
                                offer.provider!.speciality!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: DesignTokens.info,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Status badge
              _buildStatusBadge(offer.status),
            ],
          ),

 SizedBox(height: DesignTokens.space16),

          // Offer details
          Row(
            children: [
              // Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
 Text(
                      'Teklif Tutarı',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.gray600,
                      ),
                    ),
 SizedBox(height: 2),
                    Text(
                      '₺${offer.amount.toInt()} ${offer.currency}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.primaryCoral,
                      ),
                    ),
                  ],
                ),
              ),
              
              // ETA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
 Text(
                      'Teslim Süresi',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.gray600,
                      ),
                    ),
 SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color: DesignTokens.gray700,
                        ),
 SizedBox(width: 4),
                        Text(
                          '${offer.etaDays} gün',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.gray900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Created date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
 Text(
                      'Teklif Tarihi',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.gray600,
                      ),
                    ),
 SizedBox(height: 2),
                    Text(
                      _formatDate(DateTime.tryParse(offer.createdAt) ?? DateTime.now()),
                      style: const TextStyle(
                        fontSize: 13,
                        color: DesignTokens.gray700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Note section (if exists)
          if (offer.note != null && offer.note!.isNotEmpty) ...[
 SizedBox(height: DesignTokens.space12),
            Container(
              padding: EdgeInsets.all(DesignTokens.space12),
              decoration: BoxDecoration(
                color: DesignTokens.gray50,
                borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
                border: Border.all(
                  color: DesignTokens.gray200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
 Text(
                    'Not',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.gray700,
                    ),
                  ),
 SizedBox(height: 4),
                  Text(
                    offer.note!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DesignTokens.gray700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Actions section (if enabled)
          if (showActions) ...[
 SizedBox(height: DesignTokens.space16),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData? icon;

    switch (status) {
      case 'active':
        color = DesignTokens.info;
        text = 'Aktif';
        icon = Icons.hourglass_empty;
        break;
      case 'accepted':
        color = DesignTokens.success;
        text = 'Kabul Edildi';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        color = DesignTokens.error;
        text = 'Reddedildi';
        icon = Icons.cancel_outlined;
        break;
      case 'withdrawn':
        color = DesignTokens.gray500;
        text = 'Geri Çekildi';
        icon = Icons.undo_outlined;
        break;
      default:
        color = DesignTokens.gray500;
        text = 'Bilinmeyen';
        icon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.space8,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
 SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!showActions) return const SizedBox.shrink();

    if (isOwner && offer.status == 'active') {
      // Listing owner can accept or reject
      return Row(
        children: [
          Expanded(
            child: AirbnbButton(
              text: 'Reddet',
              onPressed: onReject,
              type: AirbnbButtonType.outline,
              size: AirbnbButtonSize.small,
              icon: Icons.close,
            ),
          ),
 SizedBox(width: DesignTokens.space8),
          Expanded(
            flex: 2,
            child: AirbnbButton(
              text: 'Kabul Et',
              onPressed: onAccept,
              type: AirbnbButtonType.primary,
              size: AirbnbButtonSize.small,
              icon: Icons.check,
            ),
          ),
        ],
      );
    } else if (!isOwner && offer.status == 'active') {
      // Offer owner can withdraw
      return AirbnbButton(
        text: 'Teklifi Geri Çek',
        onPressed: onWithdraw,
        type: AirbnbButtonType.outline,
        size: AirbnbButtonSize.small,
        icon: Icons.undo,
      );
    }

    return const SizedBox.shrink();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }
}