import 'package:flutter/material.dart';

class PropertyCardComponent extends StatelessWidget {
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String location;
  final String title;
  final String bedInfo;
  final String distanceInfo;
  final String dateRange;
  final double price;
  final double totalPrice;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const PropertyCardComponent({
    Key? key,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.title,
    required this.bedInfo,
    required this.distanceInfo,
    required this.dateRange,
    required this.price,
    required this.totalPrice,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                  child: Container(
                    height: 200.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {},
                      ),
                    ),
                    child: imageUrl.isEmpty
                        ? Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 12.0,
                  right: 12.0,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? const Color(0xFFE91E63) : Colors.grey,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
                // Page Indicators
                Positioned(
                  bottom: 12.0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        width: 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color: index == 0 ? Colors.white : Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and Location
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.black,
                        size: 16.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '$rating ($reviewCount)',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  // Location
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  // Bed Info
                  Text(
                    bedInfo,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  // Distance Info
                  Text(
                    distanceInfo,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Date Range
                  Text(
                    dateRange,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${price.toInt()}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        ' night',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '\$${totalPrice.toInt()} total',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}