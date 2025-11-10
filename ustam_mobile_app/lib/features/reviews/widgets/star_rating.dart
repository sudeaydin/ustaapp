import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showRating;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor()
                ? Icons.star
                : index < rating
                    ? Icons.star_half
                    : Icons.star_border,
            size: size,
            color: color ?? Colors.amber,
          );
        }),
        if (showRating) ...[
 SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w600,
              color: DesignTokens.gray600,
            ),
          ),
        ],
      ],
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const InteractiveStarRating({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1.0;
            });
            widget.onRatingChanged(_rating);
          },
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            size: widget.size,
            color: index < _rating
                ? (widget.activeColor ?? Colors.amber)
                : (widget.inactiveColor ?? Colors.grey[300]),
          ),
        );
      }),
    );
  }
}

class CategoryRatingWidget extends StatelessWidget {
  final String title;
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double size;

  const CategoryRatingWidget({
    super.key,
    required this.title,
    required this.rating,
    required this.onRatingChanged,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.surfacePrimary,
        borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
        border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InteractiveStarRating(
                initialRating: rating,
                onRatingChanged: onRatingChanged,
                size: size,
                activeColor: DesignTokens.primaryCoral,
              ),
              const SizedBox(width: 12),
              Text(
                rating > 0 ? rating.toStringAsFixed(1) : 'Puanla',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: rating > 0 ? DesignTokens.gray900 : DesignTokens.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryRatingDisplay extends StatelessWidget {
  final String title;
  final double rating;
  final IconData icon;
  final Color color;

  const CategoryRatingDisplay({
    super.key,
    required this.title,
    required this.rating,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}