import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool allowHalfRating;
  final bool isInteractive;
  final ValueChanged<int>? onRatingChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 24,
    this.allowHalfRating = true,
    this.isInteractive = false,
    this.onRatingChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return GestureDetector(
          onTap: isInteractive && onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: _buildStar(index + 1),
          ),
        );
      }),
    );
  }

  Widget _buildStar(int starNumber) {
    IconData iconData;
    Color color;

    if (allowHalfRating) {
      if (rating >= starNumber) {
        iconData = Icons.star;
        color = activeColor ?? Colors.amber;
      } else if (rating >= starNumber - 0.5) {
        iconData = Icons.star_half;
        color = activeColor ?? Colors.amber;
      } else {
        iconData = Icons.star_border;
        color = inactiveColor ?? Colors.grey[400]!;
      }
    } else {
      if (rating >= starNumber) {
        iconData = Icons.star;
        color = activeColor ?? Colors.amber;
      } else {
        iconData = Icons.star_border;
        color = inactiveColor ?? Colors.grey[400]!;
      }
    }

    return Icon(
      iconData,
      size: size,
      color: color,
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final int initialRating;
  final int maxRating;
  final double size;
  final ValueChanged<int>? onRatingChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? label;

  const InteractiveStarRating({
    super.key,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 32,
    this.onRatingChanged,
    this.activeColor,
    this.inactiveColor,
    this.label,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            ...List.generate(widget.maxRating, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentRating = index + 1;
                  });
                  widget.onRatingChanged?.call(_currentRating);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    _currentRating > index ? Icons.star : Icons.star_border,
                    size: widget.size,
                    color: _currentRating > index
                        ? (widget.activeColor ?? Colors.amber)
                        : (widget.inactiveColor ?? Colors.grey[400]),
                  ),
                ),
              );
            }),
            if (_currentRating > 0) ...[
              const SizedBox(width: 12),
              Text(
                _getRatingText(_currentRating),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Çok Kötü';
      case 2:
        return 'Kötü';
      case 3:
        return 'Orta';
      case 4:
        return 'İyi';
      case 5:
        return 'Mükemmel';
      default:
        return '';
    }
  }
}