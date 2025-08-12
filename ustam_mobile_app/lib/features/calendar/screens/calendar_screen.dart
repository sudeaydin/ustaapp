import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/calendar_provider.dart' as calendar_provider;
import '../models/appointment_model.dart';
import '../widgets/appointment_card.dart';
import '../widgets/create_appointment_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final String userType;

  const CalendarScreen({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Helper function to check if two dates are the same day
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    
    // Load events (appointments + jobs)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendar_provider.calendarProvider.notifier).loadEvents();
      ref.read(calendar_provider.calendarProvider.notifier).loadUpcomingAppointments();
      ref.read(calendar_provider.calendarProvider.notifier).loadTodayAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendar_provider.calendarProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Takvim',
        showBackButton: true,
        userType: widget.userType,
        actions: [
          IconButton(
            onPressed: () => _showCreateAppointmentSheet(context),
            icon: const Icon(Icons.add),
            tooltip: 'Randevu Oluştur',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar widget with height constraint
          SizedBox(
            height: 350, // Reduced height from 400 to 350
            child: _buildCalendar(calendarState),
          ),
          
          // Selected day appointments
          Expanded(
            child: _buildAppointmentsList(calendarState),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: widget.userType == 'customer' ? 3 : 3, // Calendar tab
        onTap: (index) {
          // Handle navigation
        },
        userType: widget.userType,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateAppointmentSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar(calendar_provider.CalendarState calendarState) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.getGradient(AppColors.primaryGradient),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                ),
                Text(
                  '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          
          // Weekday Headers
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                  .map((day) => Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          
          // Calendar Grid - wrapped with Expanded to fit remaining space
          Expanded(
            child: _buildCalendarGrid(calendarState),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  Widget _buildCalendarGrid(calendar_provider.CalendarState calendarState) {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    
    // Calculate total days to show (including previous/next month days)
    final daysInMonth = lastDayOfMonth.day;
    final totalCells = ((daysInMonth + firstDayWeekday - 1) / 7).ceil() * 7;
    
    return Container(
      padding: const EdgeInsets.all(8), // Reduced padding from 16 to 8
      child: GridView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(), // Changed physics
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          crossAxisSpacing: 4, // Reduced spacing
          mainAxisSpacing: 4, // Reduced spacing
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final dayOffset = index - (firstDayWeekday - 1);
          final day = DateTime(_focusedDay.year, _focusedDay.month, dayOffset + 1);
          
          // Skip if day is outside current month bounds
          if (dayOffset < 0 || dayOffset >= daysInMonth) {
            return const SizedBox();
          }
          
          final hasEvents = _hasEventsOnDay(day, calendarState);
          final isSelected = _selectedDay != null && isSameDay(_selectedDay!, day);
          final isToday = isSameDay(day, DateTime.now());
          
          return _buildDayCell(day, hasEvents, isSelected, isToday);
        },
      ),
    );
  }

  bool _hasEventsOnDay(DateTime day, calendar_provider.CalendarState calendarState) {
    final events = calendarState.eventsByDate[DateTime(day.year, day.month, day.day)] ?? [];
    return events.isNotEmpty;
  }

  Widget _buildDayCell(DateTime day, bool hasEvents, bool isSelected, bool isToday) {
    Color backgroundColor;
    Color textColor;
    
    if (isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
    } else if (hasEvents) {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.grey[700]!;
    } else {
      backgroundColor = AppColors.primary.withOpacity(0.1);
      textColor = AppColors.primary;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isToday 
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            if (hasEvents && !isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(calendar_provider.CalendarState calendarState) {
    if (calendarState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (calendarState.error != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  calendarState.error!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Tekrar Dene',
                onPressed: () {
                  ref.read(calendar_provider.calendarProvider.notifier).loadEvents();
                },
              ),
            ],
          ),
        ),
      );
    }

    final selectedDayEvents = _selectedDay != null
        ? calendarState.eventsByDate[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? []
        : <calendar_provider.CalendarEvent>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Section Header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.getGradient(AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDay != null 
                          ? '${_selectedDay!.day} ${_getMonthName(_selectedDay!.month)} ${_selectedDay!.year}'
                          : 'Tarih Seçin',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedDayEvents.isEmpty 
                          ? 'Bu tarihte etkinlik yok'
                          : '${selectedDayEvents.length} etkinlik',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: selectedDayEvents.isEmpty
              ? Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_available_outlined,
                          size: 64,
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Bu tarihte etkinlik yok',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yeni bir randevu oluşturmak için + butonuna tıklayın',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: selectedDayEvents.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(selectedDayEvents[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEventCard(calendar_provider.CalendarEvent event) {
    final isJob = event.isJob;
    final statusColor = _getEventStatusColor(event.status, isJob);
    final priorityColor = _getEventPriorityColor(event.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEventDetails(event),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isJob ? Icons.work_outline : Icons.event_outlined,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isJob ? 'İş Randevusu' : 'Etkinlik',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isJob && event.priority != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            priorityColor.withOpacity(0.1),
                            priorityColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: priorityColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        _getPriorityText(event.priority!),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: priorityColor,
                        ),
                      ),
                    ),
                ],
              ),
              
              if (event.description != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Time and Status Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusText(event.status, isJob),
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedDay != null && _selectedDay!.isAtSameMomentAs(DateTime.now())
                ? 'Bugün randevunuz yok'
                : 'Bu tarihte randevunuz yok',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni randevu oluşturmak için + butonuna tıklayın',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Randevu Oluştur',
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => _showCreateAppointmentSheet(context),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDay(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(day.year, day.month, day.day);
    
    if (selectedDate == today) {
      return 'Bugün';
    } else if (selectedDate == today.add(const Duration(days: 1))) {
      return 'Yarın';
    } else if (selectedDate == today.subtract(const Duration(days: 1))) {
      return 'Dün';
    } else {
      final months = [
        'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
      ];
      return '${day.day} ${months[day.month - 1]} ${day.year}';
    }
  }

  void _showCreateAppointmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAppointmentSheet(
        userType: widget.userType,
        selectedDate: _selectedDay,
        onAppointmentCreated: () {
          ref.read(calendar_provider.calendarProvider.notifier).loadAppointments();
        },
      ),
    );
  }

  void _showAppointmentDetail(Appointment appointment) {
    Navigator.pushNamed(
      context,
      '/appointment-detail',
      arguments: appointment,
    );
  }

  void _updateAppointmentStatus(Appointment appointment, AppointmentStatus newStatus) async {
    final success = await ref.read(calendar_provider.calendarProvider.notifier).updateAppointment(
      appointmentId: appointment.id,
      status: newStatus,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Randevu durumu güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(calendar_provider.calendarProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Randevu güncellenemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getEventStatusColor(String status, bool isJob) {
    if (isJob) {
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'accepted':
          return AppColors.primary;
        case 'in_progress':
          return Colors.blue;
        case 'completed':
          return AppColors.success;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    } else {
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'confirmed':
          return AppColors.success;
        case 'cancelled':
          return Colors.red;
        case 'completed':
          return AppColors.primary;
        default:
          return Colors.grey;
      }
    }
  }

  Color _getEventPriorityColor(String? priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'normal':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      case 'emergency':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, bool isJob) {
    if (isJob) {
      switch (status) {
        case 'pending':
          return 'Bekliyor';
        case 'accepted':
          return 'Kabul Edildi';
        case 'in_progress':
          return 'Devam Ediyor';
        case 'completed':
          return 'Tamamlandı';
        case 'cancelled':
          return 'İptal Edildi';
        default:
          return status;
      }
    } else {
      switch (status) {
        case 'pending':
          return 'Bekliyor';
        case 'confirmed':
          return 'Onaylandı';
        case 'cancelled':
          return 'İptal Edildi';
        case 'completed':
          return 'Tamamlandı';
        default:
          return status;
      }
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'Düşük';
      case 'normal':
        return 'Normal';
      case 'high':
        return 'Yüksek';
      case 'urgent':
        return 'Acil';
      case 'emergency':
        return 'Acil Durum';
      default:
        return priority;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showEventDetails(calendar_provider.CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    event.isJob ? Icons.work : Icons.event,
                    color: _getEventStatusColor(event.status, event.isJob),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.description != null) ...[
                      const Text(
                        'Açıklama',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    const Text(
                      'Detaylar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildDetailRow('Tarih', '${event.startTime.day}/${event.startTime.month}/${event.startTime.year}'),
                    _buildDetailRow('Saat', '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}'),
                    _buildDetailRow('Durum', _getStatusText(event.status, event.isJob)),
                    
                    if (event.location != null)
                      _buildDetailRow('Konum', event.location!),
                    
                    if (event.isJob) ...[
                      if (event.category != null)
                        _buildDetailRow('Kategori', event.category!),
                      if (event.priority != null)
                        _buildDetailRow('Öncelik', _getPriorityText(event.priority!)),
                      if (event.estimatedCost != null)
                        _buildDetailRow('Tahmini Maliyet', '${event.estimatedCost!.toStringAsFixed(0)} ₺'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}