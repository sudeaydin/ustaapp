import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/airbnb_card.dart';

class ListingOffersScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> listing;
  
  const ListingOffersScreen({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<ListingOffersScreen> createState() => _ListingOffersScreenState();
}

class _ListingOffersScreenState extends ConsumerState<ListingOffersScreen> {
  // Mock offers data
  late List<Map<String, dynamic>> _mockOffers;

  @override
  void initState() {
    super.initState();
    _mockOffers = [
      {
        'id': '1',
        'craftsmanName': 'Ahmet Yılmaz',
        'craftsmanRating': 4.8,
        'craftsmanReviewCount': 124,
        'amount': '₺650',
        'estimatedDuration': '2-3 gün',
        'note': 'Bu tür elektrik işlerinde 15 yıllık deneyimim var. Kaliteli malzeme kullanırım ve işim garantilidir.',
        'submittedAt': '2 saat önce',
        'status': 'pending', // pending, accepted, rejected
        'craftsmanImage': null,
      },
      {
        'id': '2',
        'craftsmanName': 'Mehmet Kaya',
        'craftsmanRating': 4.6,
        'craftsmanReviewCount': 89,
        'amount': '₺550',
        'estimatedDuration': '1-2 gün',
        'note': 'Hızlı ve güvenilir hizmet. Aynı gün içinde işinizi tamamlayabilirim.',
        'submittedAt': '5 saat önce',
        'status': 'pending',
        'craftsmanImage': null,
      },
      {
        'id': '3',
        'craftsmanName': 'Ali Demir',
        'craftsmanRating': 4.9,
        'craftsmanReviewCount': 156,
        'amount': '₺700',
        'estimatedDuration': '3-4 gün',
        'note': 'Profesyonel elektrik tesisatı hizmeti. Tüm işlerimde 2 yıl garanti veriyorum.',
        'submittedAt': '1 gün önce',
        'status': 'accepted',
        'craftsmanImage': null,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final pendingOffers = _mockOffers.where((offer) => offer['status'] == 'pending').toList();
    final acceptedOffers = _mockOffers.where((offer) => offer['status'] == 'accepted').toList();
    
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: CommonAppBar(
        title: 'Gelen Teklifler',
        showBackButton: true,
        userType: 'customer',
      ),
      body: _mockOffers.isEmpty ? _buildEmptyState() : _buildOffersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: DesignTokens.gray400,
          ),
          const SizedBox(height: DesignTokens.space16),
          const Text(
            'Henüz Teklif Gelmemiş',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlanınız yayında, ustalar teklif vermeye başladığında burada görünecek.',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList() {
    final pendingOffers = _mockOffers.where((offer) => offer['status'] == 'pending').toList();
    final acceptedOffers = _mockOffers.where((offer) => offer['status'] == 'accepted').toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Listing Summary
          AirbnbCard(
            backgroundColor: DesignTokens.primaryCoral.withOpacity(0.05),
            border: Border.all(color: DesignTokens.primaryCoral.withOpacity(0.2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listing['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Bütçe: ${widget.listing['budget']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: DesignTokens.gray600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_mockOffers.length} Teklif',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.primaryCoral,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space20),
          
          // Accepted Offers
          if (acceptedOffers.isNotEmpty) ...[
            const Text(
              'Kabul Edilen Teklif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignTokens.success,
              ),
            ),
            const SizedBox(height: 12),
            ...acceptedOffers.map((offer) => _buildOfferCard(offer, true)),
            const SizedBox(height: DesignTokens.space20),
          ],
          
          // Pending Offers
          if (pendingOffers.isNotEmpty) ...[
            Text(
              acceptedOffers.isEmpty ? 'Gelen Teklifler' : 'Diğer Teklifler',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignTokens.gray900,
              ),
            ),
            const SizedBox(height: 12),
            ...pendingOffers.map((offer) => _buildOfferCard(offer, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, bool isAccepted) {
    // Check if any offer is accepted to determine if this listing is closed
    final hasAcceptedOffer = _mockOffers.any((o) => o['status'] == 'accepted');
    final isThisOfferAccepted = offer['status'] == 'accepted';
    final isThisOfferRejected = offer['status'] == 'rejected';
    final canAcceptOffer = !hasAcceptedOffer && offer['status'] == 'pending';
    
    return AirbnbCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
      backgroundColor: isThisOfferAccepted 
          ? DesignTokens.success.withOpacity(0.05)
          : isThisOfferRejected
              ? DesignTokens.gray100
              : DesignTokens.surfacePrimary,
      border: isThisOfferAccepted 
          ? Border.all(color: DesignTokens.success.withOpacity(0.3))
          : isThisOfferRejected
              ? Border.all(color: DesignTokens.gray300)
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Craftsman Header
          Row(
            children: [
              // Profile Image Placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: DesignTokens.gray300,
                  borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
                ),
                child: const Icon(
                  Icons.person,
                  size: 24,
                  color: DesignTokens.gray600,
                ),
              ),
              const SizedBox(width: 12),
              
              // Craftsman Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          offer['craftsmanName'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isThisOfferRejected 
                                ? DesignTokens.gray500 
                                : DesignTokens.gray900,
                          ),
                        ),
                        if (isThisOfferAccepted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: DesignTokens.success,
                              borderRadius: const Borderconst Radius.circular(4),
                            ),
                            child: const Text(
                              'SEÇİLDİ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ] else if (isThisOfferRejected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: DesignTokens.gray500,
                              borderRadius: const Borderconst Radius.circular(4),
                            ),
                            child: const Text(
                              'REDDEDİLDİ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${offer['craftsmanRating']} (${offer['craftsmanReviewCount']} değerlendirme)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isThisOfferRejected 
                                ? DesignTokens.gray400 
                                : DesignTokens.gray600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Amount and Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    offer['amount'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isThisOfferRejected 
                          ? DesignTokens.gray500 
                          : DesignTokens.gray900,
                    ),
                  ),
                  Text(
                    offer['estimatedDuration'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isThisOfferRejected 
                          ? DesignTokens.gray400 
                          : DesignTokens.gray600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Note
          if (offer['note'].isNotEmpty) ...[
            Text(
              offer['note'],
              style: TextStyle(
                fontSize: 14,
                color: isThisOfferRejected 
                    ? DesignTokens.gray500 
                    : DesignTokens.gray700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Footer
          Row(
            children: [
              Text(
                offer['submittedAt'],
                style: const TextStyle(
                  fontSize: 12,
                  color: DesignTokens.gray500,
                ),
              ),
              const Spacer(),
              
              // Action Buttons
              if (isThisOfferAccepted) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    // Create conversation object for the craftsman
                    final conversation = {
                      'id': offer['id'], // Use offer ID as conversation ID
                      'name': offer['craftsmanName'],
                      'business_name': '${offer['craftsmanName']} Hizmetleri',
                      'avatar': 'https://picsum.photos/400/400?random=${offer['id']}',
                      'lastMessage': 'Teklifiniz kabul edildi! İş detaylarını konuşalım.',
                      'timestamp': 'Şimdi',
                      'unreadCount': 0,
                      'isOnline': true,
                      'status': 'accepted',
                      'statusIcon': '✅',
                      'jobTitle': widget.listing['title'],
                      'craftsmanRating': offer['craftsmanRating'],
                      'craftsmanReviewCount': offer['craftsmanReviewCount'],
                      'offerAmount': offer['amount'],
                      'estimatedDuration': offer['estimatedDuration'],
                    };
                    
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {'conversation': conversation},
                    );
                  },
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('Mesaj', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryCoral,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 32),
                  ),
                ),
              ] else if (canAcceptOffer) ...[
                // Only show accept/reject buttons if no offer is accepted yet
                OutlinedButton(
                  onPressed: () => _showRejectDialog(offer),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    minimumSize: const Size(60, 32),
                  ),
                  child: const Text('Reddet', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showAcceptDialog(offer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 32),
                  ),
                  child: const Text('Kabul Et', style: TextStyle(fontSize: 12)),
                ),
              ] else if (isThisOfferRejected) ...[
                // Show rejected status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DesignTokens.gray200,
                    borderRadius: const Borderconst Radius.circular(6),
                  ),
                  child: const Text(
                    'Reddedildi',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else if (hasAcceptedOffer && !isThisOfferAccepted) ...[
                // Show that listing is closed for other offers
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DesignTokens.warning.withOpacity(0.1),
                    borderRadius: const Borderconst Radius.circular(6),
                  ),
                  child: const Text(
                    'İlan Kapandı',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teklifi Kabul Et'),
        content: Text('${offer['craftsmanName']} adlı ustanın ${offer['amount']} tutarındaki teklifini kabul etmek istediğinizden emin misiniz?\n\nBu teklifi kabul ettiğinizde ilan kapanacak ve diğer ustalar teklif veremeyecektir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                offer['status'] = 'accepted';
                // Don't automatically reject other offers
                // They will show as "İlan Kapandı" instead
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${offer['craftsmanName']} adlı ustanın teklifi kabul edildi!'),
                  backgroundColor: DesignTokens.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: DesignTokens.success),
            child: const Text('Kabul Et'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teklifi Reddet'),
        content: Text('${offer['craftsmanName']} adlı ustanın teklifini reddetmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                offer['status'] = 'rejected';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teklif reddedildi')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
  }
}