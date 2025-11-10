import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

class SearchMapView extends StatefulWidget {
  final List<Map<String, dynamic>> craftsmen;
  final bool isLoading;
  final ValueChanged<Map<String, dynamic>>? onCraftsmanTap;

  const SearchMapView({
    super.key,
    required this.craftsmen,
    this.isLoading = false,
    this.onCraftsmanTap,
  });

  @override
  State<SearchMapView> createState() => _SearchMapViewState();
}

class _SearchMapViewState extends State<SearchMapView> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // For now, show a placeholder map view
    // In production, you would integrate with Google Maps or another map provider
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Stack(
        children: [
          // Map placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryCoral.withOpacity(0.1),
                    borderRadius: const BorderRadius.circular(DesignTokens.radius16),
                    border: Border.all(
                      color: DesignTokens.primaryCoral.withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 64,
                        color: DesignTokens.primaryCoral.withOpacity(0.7),
                      ),
                      const SizedBox(height: DesignTokens.space16),
                      Text(
                        'Harita Görünümü',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.primaryCoral,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Google Maps entegrasyonu\nçok yakında!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.space24),
                Text(
                  '${widget.craftsmen.length} usta bulundu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // City distribution overlay
          if (widget.craftsmen.isNotEmpty)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: _buildCityDistribution(),
            ),

          // Legend
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildMapLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildCityDistribution() {
    // Group craftsmen by city
    final cityGroups = <String, List<Map<String, dynamic>>>{};
    for (final craftsman in widget.craftsmen) {
      final city = craftsman['city'] ?? 'Bilinmeyen';
      cityGroups.putIfAbsent(city, () => []);
      cityGroups[city]!.add(craftsman);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(DesignTokens.radius12)),
      child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: DesignTokens.primaryCoral,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Şehir Dağılımı',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...cityGroups.entries.take(5).map((entry) {
              final percentage = (entry.value.length / widget.craftsmen.length * 100);
              return const Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCityColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '${entry.value.length} (${percentage.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (cityGroups.length > 5) ...[
 SizedBox(height: 4),
              Text(
                '+${cityGroups.length - 5} diğer şehir',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapLegend() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(DesignTokens.radius12)),
      child: const Padding(
      padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Açıklama',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildLegendItem(
              DesignTokens.primaryCoral,
              'Doğrulanmış Usta',
              Icons.verified,
            ),
            _buildLegendItem(
              DesignTokens.primaryCoral,
              'Portföylü Usta',
              Icons.photo_library,
            ),
            _buildLegendItem(
              DesignTokens.primaryCoral,
              'Yeni Usta',
              Icons.new_releases,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, IconData icon) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getCityColor(String city) {
    // Generate consistent colors for cities
    final colors = [
      DesignTokens.primaryCoral,
      DesignTokens.primaryCoral,
      DesignTokens.primaryCoral,
      DesignTokens.primaryCoral,
      DesignTokens.primaryCoral,
      DesignTokens.primaryCoral,
      DesignTokens.primaryCoral,
      Colors.pink,
    ];
    
    final index = city.hashCode % colors.length;
    return colors[index.abs()];
  }
}