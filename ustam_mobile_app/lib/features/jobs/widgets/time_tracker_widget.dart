import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TimeTrackerWidget extends StatefulWidget {
  final Map<String, dynamic>? currentJob;

  const TimeTrackerWidget({
    Key? key,
    this.currentJob,
  }) : super(key: key);

  @override
  State<TimeTrackerWidget> createState() => _TimeTrackerWidgetState();
}

class _TimeTrackerWidgetState extends State<TimeTrackerWidget> {
  bool isTracking = false;
  Duration elapsedTime = Duration.zero;
  DateTime? startTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Zaman Takibi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _formatDuration(elapsedTime),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isTracking ? 'Çalışıyor...' : 'Durduruldu',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _toggleTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTracking ? AppColors.error : AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isTracking ? 'Durdur' : 'Başla',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Sıfırla',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          if (widget.currentJob != null) ...[
            const SizedBox(height: 16),
            Text(
              'İş: ${widget.currentJob!['title'] ?? 'İsimsiz İş'}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleTracking() {
    setState(() {
      if (isTracking) {
        // Stop tracking
        isTracking = false;
        if (startTime != null) {
          elapsedTime += DateTime.now().difference(startTime!);
        }
      } else {
        // Start tracking
        isTracking = true;
        startTime = DateTime.now();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      isTracking = false;
      elapsedTime = Duration.zero;
      startTime = null;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}