import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/design_tokens.dart';
import '../providers/review_provider.dart';
import '../widgets/star_rating.dart';

class CreateReviewScreen extends ConsumerStatefulWidget {
  final int craftsmanId;
  final int quoteId;
  final String craftsmanName;
  final String? serviceName;

  const CreateReviewScreen({
    super.key,
    required this.craftsmanId,
    required this.quoteId,
    required this.craftsmanName,
    this.serviceName,
  });

  @override
  ConsumerState<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends ConsumerState<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  
  double _communicationRating = 0;
  double _qualityRating = 0;
  double _speedRating = 0;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  double get _overallRating {
    if (_communicationRating == 0 && _qualityRating == 0 && _speedRating == 0) {
      return 0;
    }
    return (_communicationRating + _qualityRating + _speedRating) / 3;
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Değerlendirme Yap',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              _buildHeaderInfo(),
              
              const SizedBox(height: DesignTokens.space24),
              
              // Overall rating
              _buildOverallRating(),
              
              const SizedBox(height: DesignTokens.space24),
              
              // Title field
              _buildTitleField(),
              
              const SizedBox(height: DesignTokens.space16),
              
              // Comment field
              _buildCommentField(),
              
              const SizedBox(height: DesignTokens.space24),
              
              // Detailed ratings
              _buildDetailedRatings(),
              
              const SizedBox(height: 32),
              
              // Submit button
              _buildSubmitButton(reviewState),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.primaryCoral.withOpacity(0.1),
        borderRadius: const BorderRadius.circular(DesignTokens.radius12),
        border: Border.all(
          color: DesignTokens.primaryCoral.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: DesignTokens.primaryCoral,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Usta: ${widget.craftsmanName}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (widget.serviceName != null) ...[
 SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.build,
                  color: DesignTokens.primaryCoral,
                  size: 20,
                ),
 SizedBox(width: 8),
                Text(
                  'Hizmet: ${widget.serviceName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallRating() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.surfacePrimary,
        borderRadius: const BorderRadius.circular(DesignTokens.radius12),
        border: Border.all(color: DesignTokens.primaryCoral.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
 Text(
            'Genel Değerlendirme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
 SizedBox(height: 12),
          Row(
            children: [
              StarRating(
                rating: _overallRating,
                size: 32,
                showRating: true,
              ),
              const Spacer(),
              if (_overallRating > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryCoral.withOpacity(0.1),
                    borderRadius: const BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getRatingText(_overallRating),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.primaryCoral,
                    ),
                  ),
                ),
            ],
          ),
          if (_overallRating == 0) ...[
 SizedBox(height: 8),
            Text(
              'Aşağıdaki kategorileri puanlayın',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Mükemmel';
    if (rating >= 3.5) return 'İyi';
    if (rating >= 2.5) return 'Orta';
    if (rating >= 1.5) return 'Kötü';
    return 'Çok Kötü';
  }

  Widget _buildTitleField() {
    return CustomTextField(
      label: 'Başlık (İsteğe bağlı)',
      hint: 'Değerlendirmeniz için kısa bir başlık',
      controller: _titleController,
    );
  }

  Widget _buildCommentField() {
    return CustomTextField(
      label: 'Yorumunuz',
      hint: 'Deneyiminizi detaylı olarak anlatın...',
      type: TextFieldType.multiline,
      maxLines: 4,
      controller: _commentController,
      required: true,
    );
  }

  Widget _buildDetailedRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
 Text(
          'Kategoriler *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
 SizedBox(height: 8),
        Text(
          'Her kategoriyi puanlayın (Genel puan otomatik hesaplanacak)',
          style: TextStyle(
            fontSize: 14,
            color: DesignTokens.textLight,
          ),
        ),
 SizedBox(height: DesignTokens.space16),
        
        CategoryRatingWidget(
          title: 'İletişim',
          rating: _communicationRating,
          onRatingChanged: (rating) => setState(() => _communicationRating = rating),
        ),
        
 SizedBox(height: 12),
        
        CategoryRatingWidget(
          title: 'İş Kalitesi',
          rating: _qualityRating,
          onRatingChanged: (rating) => setState(() => _qualityRating = rating),
        ),
        
 SizedBox(height: 12),
        
        CategoryRatingWidget(
          title: 'Hız & Dakiklik',
          rating: _speedRating,
          onRatingChanged: (rating) => setState(() => _speedRating = rating),
        ),
      ],
    );
  }



  Widget _buildSubmitButton(ReviewState reviewState) {
    return CustomButton(
      text: 'Değerlendirmeyi Gönder',
      type: ButtonType.primary,
      isFullWidth: true,
      isLoading: reviewState.isLoading,
      enabled: _communicationRating > 0 && _qualityRating > 0 && _speedRating > 0 && _commentController.text.trim().length >= 10,
      onPressed: _submitReview,
    );
  }

  void _submitReview() async {
    if (!_formKey.currentState!.validate() || 
        _communicationRating == 0 || 
        _qualityRating == 0 || 
        _speedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm kategorileri puanlayın ve yorum yazın'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref.read(reviewProvider.notifier).createReview(
      craftsmanId: widget.craftsmanId,
      quoteId: widget.quoteId,
      rating: _overallRating.round(),
      title: _titleController.text.trim().isNotEmpty 
          ? _titleController.text.trim() 
          : null,
      comment: _commentController.text.trim(),
      qualityRating: _qualityRating.round(),
      punctualityRating: _speedRating.round(),
      communicationRating: _communicationRating.round(),
      cleanlinessRating: null, // This field is no longer used in the new 3-category system
    );

    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Değerlendirmeniz başarıyla gönderildi'),
            backgroundColor: DesignTokens.primaryCoral,
          ),
        );
      }
    }
  }
}