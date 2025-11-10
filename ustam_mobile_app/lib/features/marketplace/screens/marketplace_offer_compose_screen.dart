import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_input.dart';
import '../models/marketplace_listing.dart';
import '../repositories/marketplace_repository.dart';
import '../providers/marketplace_provider.dart';
import '../../auth/providers/auth_provider.dart';

class MarketplaceOfferComposeScreen extends ConsumerStatefulWidget {
  final String listingId;

  const MarketplaceOfferComposeScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<MarketplaceOfferComposeScreen> createState() =>
      _MarketplaceOfferComposeScreenState();
}

class _MarketplaceOfferComposeScreenState
    extends ConsumerState<MarketplaceOfferComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _etaDaysController = TextEditingController(text: '3');

  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _etaDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userType = authState.user?['user_type'] ?? 'customer';
    
    // Only craftsmen can submit offers
    if (userType != 'craftsman') {
      return Scaffold(
        appBar: CommonAppBar(
          title: 'Teklif Ver',
          userType: userType,
          showBackButton: true,
        ),
        body: const Center(
          child: Text(
            'Bu özellik sadece ustalar için kullanılabilir.',
            style: TextStyle(
              fontSize: 16,
              color: DesignTokens.gray600,
            ),
          ),
        ),
      );
    }

    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: CommonAppBar(
        title: 'Teklif Ver',
        userType: userType,
        showBackButton: true,
      ),
      body: listingAsync.when(
        data: (listingDetail) => _buildContent(listingDetail.listing),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildContent(MarketplaceListing listing) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Listing summary
          _buildListingSummary(listing),

          // Offer form
          _buildOfferForm(listing),

          // Submit button
          _buildSubmitSection(listing),

          const SizedBox(height: DesignTokens.space24),
        ],
      ),
    );
  }

  Widget _buildListingSummary(MarketplaceListing listing) {
    return AirbnbCard(
      margin: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 24,
                color: DesignTokens.primaryCoral,
              ),
              const SizedBox(width: DesignTokens.space8),
              const Text(
                'İş Detayları',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.gray900,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DesignTokens.space16),

          // Title
          Text(
            listing.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DesignTokens.gray900,
            ),
          ),
          
          const SizedBox(height: DesignTokens.space8),

          // Category and location
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space8,
                  vertical: DesignTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryCoral.withOpacity(0.1),
                  borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
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
              const SizedBox(width: DesignTokens.space12),
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
            ],
          ),

          const SizedBox(height: DesignTokens.space12),

          // Budget range
          Container(
            padding: const EdgeInsets.all(DesignTokens.space12),
            decoration: BoxDecoration(
              color: DesignTokens.gray50,
              borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
              border: Border.all(
                color: DesignTokens.gray200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_money_outlined,
                  size: 20,
                  color: DesignTokens.gray600,
                ),
                const SizedBox(width: DesignTokens.space8),
                const Text(
                  'Beklenen Bütçe: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignTokens.gray600,
                  ),
                ),
                Text(
                  _formatBudget(listing.budget),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.gray900,
                  ),
                ),
              ],
            ),
          ),

          // Bids count
          if (listing.bidsCount > 0) ...[
 SizedBox(height: DesignTokens.space8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.space8,
                vertical: DesignTokens.space4,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.info.withOpacity(0.1),
                borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 14,
                    color: DesignTokens.info,
                  ),
 SizedBox(width: DesignTokens.space4),
                  Text(
                    '${listing.bidsCount} kişi teklif verdi',
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
        ],
      ),
    );
  }

  Widget _buildOfferForm(MarketplaceListing listing) {
    return Form(
      key: _formKey,
      child: AirbnbCard(
        margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
            .copyWith(bottom: DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 24,
                  color: DesignTokens.primaryCoral,
                ),
 SizedBox(width: DesignTokens.space8),
 Text(
                  'Teklifinizi Oluşturun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.gray900,
                  ),
                ),
              ],
            ),

 SizedBox(height: DesignTokens.space24),

            // Amount input
            AirbnbInput(
              label: 'Teklif Tutarı (TL)',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              prefixIcon: Icons.attach_money,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen teklif tutarınızı girin';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Geçerli bir tutar girin';
                }
                if (amount < 50) {
                  return 'Minimum teklif tutarı 50 TL\'dir';
                }
                return null;
              },
            ),

 SizedBox(height: DesignTokens.space20),

            // ETA input
            AirbnbInput(
              label: 'Teslim Süresi (Gün)',
              controller: _etaDaysController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: Icons.schedule,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen teslim süresini girin';
                }
                final days = int.tryParse(value);
                if (days == null || days <= 0) {
                  return 'Geçerli bir gün sayısı girin';
                }
                if (days > 365) {
                  return 'Maksimum teslim süresi 365 gündür';
                }
                return null;
              },
            ),

 SizedBox(height: DesignTokens.space20),

            // Note input
            AirbnbInput(
              label: 'Not (İsteğe Bağlı)',
              controller: _noteController,
              maxLines: 4,
              prefixIcon: Icons.note_outlined,
              hintText: 'İş hakkında düşünceleriniz, deneyiminiz veya özel notlarınız...',
              validator: (value) {
                if (value != null && value.length > 500) {
                  return 'Not maksimum 500 karakter olabilir';
                }
                return null;
              },
            ),

 SizedBox(height: DesignTokens.space24),

            // Tips section
            Container(
              padding: EdgeInsets.all(DesignTokens.space16),
              decoration: BoxDecoration(
                color: DesignTokens.info.withOpacity(0.05),
                borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
                border: Border.all(
                  color: DesignTokens.info.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: DesignTokens.info,
                      ),
 SizedBox(width: DesignTokens.space8),
 Text(
                        'Teklif İpuçları',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.gray900,
                        ),
                      ),
                    ],
                  ),
 SizedBox(height: DesignTokens.space8),
                  _buildTip('Gerçekçi bir fiyat belirleyin'),
                  _buildTip('Deneyiminizi ve uzmanlığınızı vurgulayın'),
                  _buildTip('İşin detayları hakkında sorularınızı belirtin'),
                  _buildTip('Profesyonel bir dil kullanın'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(top: DesignTokens.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: DesignTokens.info,
              borderRadius: const Borderconst Radius.circular(2),
            ),
          ),
 SizedBox(width: DesignTokens.space8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: DesignTokens.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitSection(MarketplaceListing listing) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignTokens.space16),
      child: Column(
        children: [
          // Terms reminder
          Container(
            padding: EdgeInsets.all(DesignTokens.space12),
            decoration: BoxDecoration(
              color: DesignTokens.warning.withOpacity(0.05),
              borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
              border: Border.all(
                color: DesignTokens.warning.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: DesignTokens.warning,
                ),
 SizedBox(width: DesignTokens.space8),
                const Expanded(
                  child: Text(
                    'Teklif verdiğinizde müşteri ile iletişime geçebilir ve işi kabul edebilir.',
                    style: TextStyle(
                      fontSize: 13,
                      color: DesignTokens.gray700,
                    ),
                  ),
                ),
              ],
            ),
          ),

 SizedBox(height: DesignTokens.space16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: AirbnbButton(
              text: _isSubmitting ? 'Gönderiliyor...' : 'Teklif Gönder',
              onPressed: _isSubmitting ? null : () => _submitOffer(listing),
              type: AirbnbButtonType.primary,
              size: AirbnbButtonSize.large,
              icon: _isSubmitting ? null : Icons.send_outlined,
            ),
          ),
        ],
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
 SizedBox(height: DesignTokens.space16),
 Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignTokens.gray900,
              ),
            ),
 SizedBox(height: DesignTokens.space8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.gray600,
              ),
              textAlign: TextAlign.center,
            ),
 SizedBox(height: DesignTokens.space24),
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

  String _formatBudget(ListingBudget budget) {
    if (budget.type == 'fixed') {
      return '₺${budget.min.toInt()} (Sabit)';
    } else {
      return '₺${budget.min.toInt()} - ₺${budget.max.toInt()}';
    }
  }

  Future<void> _submitOffer(MarketplaceListing listing) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final etaDays = int.parse(_etaDaysController.text);
      final note = _noteController.text.trim().isEmpty 
          ? null 
          : _noteController.text.trim();

      // Submit offer using provider
      final request = SubmitOfferRequest(
        amount: amount,
        etaDays: etaDays,
        note: note,
      );

      await ref.read(submitOfferProvider.notifier).submitOffer(
        widget.listingId,
        request,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teklifiniz başarıyla gönderildi!'),
            backgroundColor: DesignTokens.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to listing detail
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: DesignTokens.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}