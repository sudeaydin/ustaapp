import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../models/marketplace_listing.dart';
import '../providers/marketplace_provider.dart';
import '../../auth/providers/auth_provider.dart';

class MarketplaceListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const MarketplaceListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<MarketplaceListingDetailScreen> createState() =>
      _MarketplaceListingDetailScreenState();
}

class _MarketplaceListingDetailScreenState
    extends ConsumerState<MarketplaceListingDetailScreen> {
  bool _showAllOffers = false;

  @override
  void initState() {
    super.initState();
    // Load listing details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingDetailProvider(widget.listingId).future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userType = authState.user?['user_type'] ?? 'customer';
    final userId = authState.user?['id'] ?? '';

    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: CommonAppBar(
        title: 'İlan Detayı',
        userType: userType,
        showBackButton: true,
      ),
      body: listingAsync.when(
        data: (listingDetail) => _buildContent(listingDetail.listing, userType, userId),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
      bottomNavigationBar: listingAsync.maybeWhen(
        data: (listingDetail) => _buildBottomBar(listingDetail.listing, userType, userId),
        orElse: () => null,
      ),
    );
  }

  Widget _buildContent(MarketplaceListing listing, String userType, String userId) {
    final isOwner = listing.postedBy.userId == userId;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header section
          _buildHeaderSection(listing),

          // Description section
          _buildDescriptionSection(listing),

          // Details section
          _buildDetailsSection(listing),

          // Location & Budget section
          _buildLocationBudgetSection(listing),

          // Date range section
          _buildDateRangeSection(listing),

          // Attachments section (if any)
          if (listing.attachments.isNotEmpty) _buildAttachmentsSection(listing),

          // Owner actions section (if owner)
          if (isOwner) _buildOwnerActionsSection(listing),

          // Offers section
          _buildOffersSection(listing, userType, isOwner),

          const SizedBox(height: 100), // Bottom padding for floating button
        ],
      ),
    );
  }

  Widget _buildHeaderSection(MarketplaceListing listing) {
    return AirbnbCard(
      margin: EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and category row
          Row(
            children: [
              // Category chip
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.space12,
                  vertical: DesignTokens.space6,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryCoral.withOpacity(0.1),
                  borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                ),
                child: Text(
                  listing.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.primaryCoral,
                  ),
                ),
              ),
              const Spacer(),
              // Status badge
              _buildStatusBadge(listing.status),
            ],
          ),

          const SizedBox(height: DesignTokens.space16),

          // Title
          Text(
            listing.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
              height: 1.2,
            ),
          ),

          const SizedBox(height: DesignTokens.space8),

          // Posted by and date
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: DesignTokens.primaryCoral.withOpacity(0.1),
                child: Text(
                  listing.postedBy.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.primaryCoral,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.postedBy.name ?? 'Anonim Kullanıcı',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.gray900,
                      ),
                    ),
                    Text(
                      _formatDate(DateTime.tryParse(listing.postedAt) ?? DateTime.now()),
                      style: const TextStyle(
                        fontSize: 12,
                        color: DesignTokens.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              // Bids count
              if (listing.bidsCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignTokens.space8,
                    vertical: DesignTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.info.withOpacity(0.1),
                    borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer_outlined,
                        size: 14,
                        color: DesignTokens.info,
                      ),
                      const SizedBox(width: DesignTokens.space4),
                      Text(
                        '${listing.bidsCount} teklif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.info,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(MarketplaceListing listing) {
    return AirbnbCard(
      margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Açıklama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          Text(
            listing.description,
            style: const TextStyle(
              fontSize: 15,
              color: DesignTokens.gray700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(MarketplaceListing listing) {
    return AirbnbCard(
      margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İş Detayları',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          
          // Detail rows
          _buildDetailRow(
            Icons.category_outlined,
            'Kategori',
            listing.category,
          ),
          _buildDetailRow(
            Icons.visibility_outlined,
            'Görünürlük',
            listing.visibility == 'marketplace' ? 'Pazar Yerinde' : 'Özel',
          ),
          _buildDetailRow(
            Icons.access_time_outlined,
            'Yayınlanma',
            _formatDate(DateTime.tryParse(listing.postedAt) ?? DateTime.now()),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBudgetSection(MarketplaceListing listing) {
    return AirbnbCard(
      margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Row(
        children: [
          // Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: DesignTokens.primaryCoral,
                    ),
                    const SizedBox(width: DesignTokens.space8),
                    const Text(
                      'Konum',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space4),
                Padding(
      padding: EdgeInsets.only(left: 28),
                  child: Text(
                    listing.location.city,
                    style: const TextStyle(
                      fontSize: 16,
                      color: DesignTokens.gray700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Budget
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money_outlined,
                      size: 20,
                      color: DesignTokens.primaryCoral,
                    ),
                    const SizedBox(width: DesignTokens.space8),
                    const Text(
                      'Bütçe',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space4),
                Padding(
      padding: EdgeInsets.only(left: 28),
                  child: Text(
                    _formatBudget(listing.budget),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.gray900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(MarketplaceListing listing) {
    return AirbnbCard(
      margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: DesignTokens.primaryCoral,
              ),
              const SizedBox(width: DesignTokens.space8),
              const Text(
                'Tarih Aralığı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),
          Container(
            padding: EdgeInsets.all(DesignTokens.space12),
            decoration: BoxDecoration(
              color: DesignTokens.primaryCoral.withOpacity(0.05),
              borderRadius: const BorderRadius.circular(DesignTokens.radius12),
              border: Border.all(
                color: DesignTokens.primaryCoral.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Başlangıç',
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.gray600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM yyyy').format(DateTime.tryParse(listing.dateRange.start) ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: DesignTokens.gray300,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Bitiş',
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.gray600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM yyyy').format(DateTime.tryParse(listing.dateRange.end) ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(MarketplaceListing listing) {
    return AirbnbCard(
      margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ekler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          // TODO: Implement attachment display
          const Text(
            'Ek dosyalar burada gösterilecek',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerActionsSection(MarketplaceListing listing) {
    return AirbnbCard(
      margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İlan Yönetimi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          Row(
            children: [
              Expanded(
                child: AirbnbButton(
                  text: 'Düzenle',
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/marketplace/listing/${listing.id}/edit',
                    );
                  },
                  type: AirbnbButtonType.outline,
                  size: AirbnbButtonSize.medium,
                  icon: Icons.edit_outlined,
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: AirbnbButton(
                  text: listing.status == 'open' ? 'Kapat' : 'Aç',
                  onPressed: () => _toggleListingStatus(listing),
                  type: listing.status == 'open' 
                      ? AirbnbButtonType.error 
                      : AirbnbButtonType.primary,
                  size: AirbnbButtonSize.medium,
                  icon: listing.status == 'open' 
                      ? Icons.close_outlined 
                      : Icons.play_arrow_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(MarketplaceListing listing, String userType, bool isOwner) {
    // For now, we'll show a placeholder. In a real app, we'd load offers from the provider
    return AirbnbCard(
      margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Teklifler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.gray900,
                ),
              ),
              const Spacer(),
              if (listing.bidsCount > 3 && !_showAllOffers)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllOffers = true;
                    });
                  },
                  child: const Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignTokens.primaryCoral,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.space16),
          
          if (listing.bidsCount == 0)
            _buildNoOffersState()
          else
            _buildOffersPlaceholder(listing.bidsCount),
        ],
      ),
    );
  }

  Widget _buildNoOffersState() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.space24),
      decoration: BoxDecoration(
        color: DesignTokens.gray50,
        borderRadius: const BorderRadius.circular(DesignTokens.radius12),
        border: Border.all(
          color: DesignTokens.gray200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 48,
            color: DesignTokens.gray400,
          ),
          const SizedBox(height: DesignTokens.space12),
          const Text(
            'Henüz Teklif Yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DesignTokens.gray700,
            ),
          ),
          const SizedBox(height: DesignTokens.space4),
          const Text(
            'Bu iş için henüz hiç teklif gelmemiş',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersPlaceholder(int count) {
    return Column(
      children: List.generate(
        _showAllOffers ? count : (count > 3 ? 3 : count),
        (index) => Container(
          margin: EdgeInsets.only(
            bottom: index < (count - 1) ? DesignTokens.space12 : 0,
          ),
          padding: EdgeInsets.all(DesignTokens.space16),
          decoration: BoxDecoration(
            color: DesignTokens.gray50,
            borderRadius: const BorderRadius.circular(DesignTokens.radius12),
            border: Border.all(
              color: DesignTokens.gray200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: DesignTokens.primaryCoral.withOpacity(0.1),
                child: Text(
                  'U${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.primaryCoral,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usta ${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(index + 1) * 500 + 1000} TL - ${index + 2} gün',
                      style: const TextStyle(
                        fontSize: 13,
                        color: DesignTokens.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₺${(index + 1) * 500 + 1000}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.primaryCoral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(MarketplaceListing listing, String userType, String userId) {
    final isOwner = listing.postedBy.userId == userId;
    
    if (isOwner || listing.status != 'open') {
      return const SizedBox.shrink(); // No action needed for owner or closed listings
    }

    if (userType != 'craftsman') {
      return const SizedBox.shrink(); // Only craftsmen can make offers
    }

    return Container(
      padding: EdgeInsets.only(
        left: DesignTokens.space16,
        right: DesignTokens.space16,
        top: DesignTokens.space16,
        bottom: DesignTokens.space16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.surfacePrimary,
        boxShadow: [
          BoxShadow(
            color: DesignTokens.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AirbnbButton(
        text: 'Teklif Ver',
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/marketplace/listing/${listing.id}/offer',
          );
        },
        type: AirbnbButtonType.primary,
        size: AirbnbButtonSize.large,
        icon: Icons.local_offer_outlined,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: const CircularProgressIndicator(
        color: DesignTokens.primaryCoral,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
      padding: EdgeInsets.all(DesignTokens.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: DesignTokens.error,
            ),
            const SizedBox(height: DesignTokens.space16),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignTokens.gray900,
              ),
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space24),
            AirbnbButton(
              text: 'Tekrar Dene',
              onPressed: () {
                ref.invalidate(listingDetailProvider(widget.listingId));
              },
              type: AirbnbButtonType.outline,
              size: AirbnbButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'open':
        color = DesignTokens.success;
        text = 'Açık';
        break;
      case 'closed':
        color = DesignTokens.error;
        text = 'Kapalı';
        break;
      case 'completed':
        color = DesignTokens.info;
        text = 'Tamamlandı';
        break;
      default:
        color = DesignTokens.gray500;
        text = 'Bilinmeyen';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.space8,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.circular(DesignTokens.radius12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.space12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: DesignTokens.gray500,
          ),
          const SizedBox(width: DesignTokens.space12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
          ),
          const SizedBox(width: DesignTokens.space8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DesignTokens.gray900,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Dün ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  String _formatBudget(ListingBudget budget) {
    if (budget.type == 'fixed') {
      return '₺${budget.min.toInt()} (Sabit)';
    } else {
      return '₺${budget.min.toInt()} - ₺${budget.max.toInt()}';
    }
  }

  void _toggleListingStatus(MarketplaceListing listing) {
    // TODO: Implement listing status toggle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: const Text('İlan durumu güncelleme özelliği yakında eklenecek'),
        backgroundColor: DesignTokens.info,
      ),
    );
  }
}