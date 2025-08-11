import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/app_colors.dart';
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

  int _overallRating = 0;
  int _qualityRating = 0;
  int _punctualityRating = 0;
  int _communicationRating = 0;
  int _cleanlinessRating = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
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
              
              const SizedBox(height: 24),
              
              // Overall rating
              _buildOverallRating(),
              
              const SizedBox(height: 24),
              
              // Title field
              _buildTitleField(),
              
              const SizedBox(height: 16),
              
              // Comment field
              _buildCommentField(),
              
              const SizedBox(height: 24),
              
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Usta: ${widget.craftsmanName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (widget.serviceName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.build,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genel Değerlendirme *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InteractiveStarRating(
          initialRating: _overallRating,
          size: 40,
          onRatingChanged: (rating) {
            setState(() {
              _overallRating = rating;
            });
          },
        ),
        if (_overallRating == 0) ...[
          const SizedBox(height: 8),
          Text(
            'Lütfen bir puan verin',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[600],
            ),
          ),
        ],
      ],
    );
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
        const Text(
          'Detaylı Değerlendirme (İsteğe bağlı)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildDetailedRatingRow(
          'Kalite',
          'İşin kalitesi nasıldı?',
          _qualityRating,
          (rating) => setState(() => _qualityRating = rating),
        ),
        
        const SizedBox(height: 16),
        
        _buildDetailedRatingRow(
          'Dakiklik',
          'Zamanında geldi mi?',
          _punctualityRating,
          (rating) => setState(() => _punctualityRating = rating),
        ),
        
        const SizedBox(height: 16),
        
        _buildDetailedRatingRow(
          'İletişim',
          'İletişimi nasıldı?',
          _communicationRating,
          (rating) => setState(() => _communicationRating = rating),
        ),
        
        const SizedBox(height: 16),
        
        _buildDetailedRatingRow(
          'Temizlik',
          'Çalışma alanını temiz bıraktı mı?',
          _cleanlinessRating,
          (rating) => setState(() => _cleanlinessRating = rating),
        ),
      ],
    );
  }

  Widget _buildDetailedRatingRow(
    String title,
    String description,
    int currentRating,
    ValueChanged<int> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          InteractiveStarRating(
            initialRating: currentRating,
            size: 28,
            onRatingChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ReviewState reviewState) {
    return CustomButton(
      text: 'Değerlendirmeyi Gönder',
      type: ButtonType.primary,
      isFullWidth: true,
      isLoading: reviewState.isLoading,
      enabled: _overallRating > 0 && _commentController.text.trim().length >= 10,
      onPressed: _submitReview,
    );
  }

  void _submitReview() async {
    if (!_formKey.currentState!.validate() || _overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm zorunlu alanları doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref.read(reviewProvider.notifier).createReview(
      craftsmanId: widget.craftsmanId,
      quoteId: widget.quoteId,
      rating: _overallRating,
      comment: _commentController.text.trim(),
      title: _titleController.text.trim().isNotEmpty 
          ? _titleController.text.trim() 
          : null,
      qualityRating: _qualityRating > 0 ? _qualityRating : null,
      punctualityRating: _punctualityRating > 0 ? _punctualityRating : null,
      communicationRating: _communicationRating > 0 ? _communicationRating : null,
      cleanlinessRating: _cleanlinessRating > 0 ? _cleanlinessRating : null,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Değerlendirmeniz başarıyla gönderildi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } else {
      final error = ref.read(reviewProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Değerlendirme gönderilemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}