import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../reviews/providers/review_provider.dart';
import '../../reviews/widgets/review_card.dart';
import '../../reviews/widgets/star_rating.dart';
import '../../reviews/screens/reviews_screen.dart';

class CraftsmanDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> craftsman;
  
  const CraftsmanDetailScreen({super.key, required this.craftsman});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar - Figma Design
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: DesignTokens.surfacePrimary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignTokens.uclaBlue,
                      DesignTokens.primaryCoral,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(24),
                    bottomRight: const Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  child: const Padding(
      padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: craftsman['avatar'] != null 
                              ? NetworkImage(craftsman['avatar']) 
                              : null,
                          backgroundColor: DesignTokens.primaryCoral.withOpacity(0.1),
                          child: craftsman['avatar'] == null 
                              ? const Icon(Icons.person, size: 40, color: DesignTokens.primaryCoral)
                              : null,
                        ),
                        const SizedBox(height: DesignTokens.space16),
                        Text(
                          craftsman['name'] ?? '',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.surfacePrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          craftsman['business_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: DesignTokens.surfacePrimary70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (craftsman['is_verified'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: DesignTokens.surfacePrimary.withOpacity(0.2),
                                  borderRadius: const Borderconst Radius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified, color: DesignTokens.surfacePrimary, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Doğrulanmış',
                                      style: TextStyle(
                                        color: DesignTokens.surfacePrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: DesignTokens.surfacePrimary),
                onPressed: () {},
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: const Padding(
      padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Değerlendirme',
                          value: '${craftsman['average_rating']?.toStringAsFixed(1) ?? '0.0'}',
                          icon: Icons.star,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Tamamlanan İş',
                          value: '${craftsman['total_reviews'] ?? 0}',
                          icon: Icons.check_circle,
                          color: DesignTokens.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Saatlik Ücret',
                          value: '${craftsman['hourly_rate'] ?? 0}₺',
                          icon: Icons.attach_money,
                          color: DesignTokens.uclaBlue,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Bio Section
                  const Text(
                    'Hakkında',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    decoration: BoxDecoration(
                      color: DesignTokens.surfacePrimary,
                      borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
                      border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      craftsman['description'] ?? 'Bu usta hakkında bilgi bulunmuyor.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: DesignTokens.textLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Skills Section
                  const Text(
                    'Yetenekler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    decoration: BoxDecoration(
                      color: DesignTokens.surfacePrimary,
                      borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
                      border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: (craftsman['skills'] as List? ?? []).map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: DesignTokens.primaryCoral.withOpacity(0.1),
                            borderRadius: const Borderconst Radius.circular(20),
                            border: Border.all(color: DesignTokens.primaryCoral),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.psychology,
                                size: 16,
                                color: DesignTokens.primaryCoral,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                skill.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: DesignTokens.primaryCoral,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Service Areas
                  const Text(
                    'Hizmet Verdiği Bölgeler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    decoration: BoxDecoration(
                      color: DesignTokens.surfacePrimary,
                      borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
                      border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: DesignTokens.uclaBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${craftsman['city'] ?? ''}, ${craftsman['district'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: DesignTokens.gray900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (craftsman['service_areas'] as List? ?? []).map((area) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F9FF),
                                borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
                                border: Border.all(color: const Color(0xFFBAE6FD)),
                              ),
                              child: Text(
                                area.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0369A1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Portfolio Section
                  const Text(
                    'Portfolyo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: DesignTokens.surfacePrimary,
                            borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
                            border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://picsum.photos/400/400?random=7',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Reviews Section
                  _buildReviewsSection(context, ref),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/quote-form', arguments: {
                                'craftsman': craftsman,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignTokens.uclaBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Teklif Al',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 56,
                        width: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to messages
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignTokens.surfacePrimary,
                            foregroundColor: DesignTokens.uclaBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
                              side: BorderSide(color: DesignTokens.uclaBlue),
                            ),
                            elevation: 0,
                          ),
                          child: const Icon(Icons.message),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.surfacePrimary,
        borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
        border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: DesignTokens.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, WidgetRef ref) {
    final craftsmanId = craftsman['id'] as int?;
    if (craftsmanId == null) return const SizedBox.shrink();

    // Load reviews when building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).loadCraftsmanReviews(craftsmanId);
    });

    final reviewState = ref.watch(reviewProvider);
    final reviews = reviewState.reviews;
    final averageRating = craftsman['average_rating'] ?? 0.0;
    final totalReviews = craftsman['total_reviews'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with rating summary
        Row(
          children: [
            const Text(
              'Müşteri Yorumları',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignTokens.gray900,
              ),
            ),
            const Spacer(),
            if (totalReviews > 0) ...[
              StarRating(
                rating: averageRating.toDouble(),
                size: 16,
              ),
 SizedBox(width: 8),
              Text(
                '${averageRating.toStringAsFixed(1)} (${totalReviews})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.gray900,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Reviews container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: DesignTokens.surfacePrimary,
            borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
            border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (reviewState.isLoading)
                const Padding(
      padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )
              else if (reviews.isNotEmpty) ...[
                // Show first 2 reviews
                ...reviews.take(2).map((review) => 
 Padding(
                    padding: EdgeInsets.all(DesignTokens.space16),
                    child: ReviewCard(
                      review: review,
                      showCustomerInfo: true,
                    ),
                  ),
                ),
                
                // "View All Reviews" button if more than 2 reviews
                if (reviews.length > 2)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(DesignTokens.space16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: DesignTokens.nonPhotoBlue.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewsScreen(
                              craftsmanId: craftsmanId,
                              craftsmanName: craftsman['name'] ?? 'Usta',
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: DesignTokens.primaryCoral,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
 Text(
                            'Tüm Yorumları Gör',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
 SizedBox(width: 8),
                          Text(
                            '(${reviews.length})',
                            style: TextStyle(
                              fontSize: 14,
                              color: DesignTokens.primaryCoral.withOpacity(0.7),
                            ),
                          ),
 SizedBox(width: 4),
 Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
              ] else
 Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
 SizedBox(height: 12),
 Text(
                        'Henüz yorum yok',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.gray600,
                        ),
                      ),
 SizedBox(height: 4),
 Text(
                        'İlk yorumu bırakın!',
                        style: TextStyle(
                          fontSize: 14,
                          color: DesignTokens.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}