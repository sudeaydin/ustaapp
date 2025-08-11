import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';

enum ChartType { bar, line, pie }

class ChartWidget extends StatelessWidget {
  final String title;
  final ChartType type;
  final List<Map<String, dynamic>> data;
  final Color? color;

  const ChartWidget({
    super.key,
    required this.title,
    required this.type,
    required this.data,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (type) {
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.line:
        return _buildLineChart();
      case ChartType.pie:
        return _buildPieChart();
    }
  }

  Widget _buildBarChart() {
    if (data.isEmpty) return const Center(child: Text('Veri bulunamadı'));

    final maxValue = data.map((e) => (e['value'] as num).toDouble()).reduce(math.max);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final value = (item['value'] as num).toDouble();
        final height = (value / maxValue) * 160;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: color ?? AppColors.primary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineChart() {
    if (data.isEmpty) return const Center(child: Text('Veri bulunamadı'));

    return CustomPaint(
      size: const Size(double.infinity, 160),
      painter: LineChartPainter(
        body: data,
        color: color ?? AppColors.primary,
      ),
    );
  }

  Widget _buildPieChart() {
    if (data.isEmpty) return const Center(child: Text('Veri bulunamadı'));

    final total = data.fold<double>(0, (sum, item) => sum + (item['value'] as num).toDouble());
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomPaint(
            size: const Size(120, 120),
            painter: PieChartPainter(
              body: data,
              total: total,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final value = (item['value'] as num).toDouble();
              final percentage = ((value / total) * 100).toStringAsFixed(1);
              final pieColor = _getPieColor(index);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: pieColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item['label']} ($percentage%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getPieColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
    ];
    return colors[index % colors.length];
  }
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color color;

  LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final maxValue = data.map((e) => (e['value'] as num).toDouble()).reduce(math.max);
    final minValue = data.map((e) => (e['value'] as num).toDouble()).reduce(math.min);
    final range = maxValue - minValue;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final value = (data[i]['value'] as num).toDouble();
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((value - minValue) / range) * size.height;
      
      points.add(Offset(x, y));
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final value = (data[i]['value'] as num).toDouble();
      final sweepAngle = (value / total) * 2 * math.pi;
      
      final paint = Paint()
        ..color = _getPieColor(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  Color _getPieColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}