import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/theme/design_tokens.dart';
import '../providers/calendar_provider.dart' as calendar_provider;
import '../models/appointment_model.dart';
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
        backgroundColor: DesignTokens.primaryCoral,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar(calendar_provider.CalendarState calendarState) {
    return Container(
      margin: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.circular(20),
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
              gradient: DesignTokens.primaryCoralGradient,
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
                  style: TextStyle(
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
    final dayKey = DateTime(day.year, day.month, day.day);
    final events = calendarState.eventsByDate[dayKey] ?? [];
    return events.isNotEmpty;
  }

  Widget _buildDayCell(DateTime day, bool hasEvents, bool isSelected, bool isToday) {
    Color backgroundColor;
    Color textColor;
    
    if (isSelected) {
      backgroundColor = DesignTokens.primaryCoral;
      textColor = Colors.white;
    } else if (hasEvents) {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.grey[700]!;
    } else {
      backgroundColor = DesignTokens.primaryCoral.withOpacity(0.1);
      textColor = DesignTokens.primaryCoral;
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
          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
          border: isToday 
            ? Border.all(color: DesignTokens.primaryCoral, width: 2)
            : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: DesignTokens.primaryCoral.withOpacity(0.3),
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
                    color: DesignTokens.primaryCoral,
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
          margin: const EdgeInsets.all(DesignTokens.space16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: DesignTokens.primaryCoralGradient,
            borderRadius: const BorderRadius.circular(DesignTokens.radius16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.circular(DesignTokens.radius12),
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
                      style: TextStyle(
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
                  margin: const EdgeInsets.all(DesignTokens.space16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.space24),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryCoral.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_available_outlined,
                          size: 64,
                          color: DesignTokens.primaryCoral.withOpacity(0.6),
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
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
                  itemCount: selectedDayEvents.length,
                  itemBuilder: (context, index) {
                    final event = selectedDayEvents[index];
                    debugPrint('📋 Building event card for: ${event.title} (${event.id})');
                    return _buildEventCard(event);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEventCard(calendar_provider.CalendarEvent event) {
    debugPrint('🎨 _buildEventCard called for: ${event.title}');
    debugPrint('🎨 Event details: ID=${event.id}, type=${event.type}, status=${event.status}');
    final isJob = event.isJob;
    final statusColor = _getEventStatusColor(event.status, isJob);
    final priorityColor = _getEventPriorityColor(event.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.circular(DesignTokens.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: const BorderRadius.circular(DesignTokens.radius16),
        onTap: () {
          debugPrint('🎯 Event card tapped! Event: ${event.title}');
          debugPrint('🎯 Event ID: ${event.id}');
          debugPrint('🎯 Event type: ${event.type}');
          try {
            _showEventDetails(event);
            debugPrint('✅ _showEventDetails called successfully');
          } catch (e, stackTrace) {
            debugPrint('❌ Error in _showEventDetails: $e');
            debugPrint('❌ Stack trace: $stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Event detayı açılırken hata: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        onTapDown: (details) {
          debugPrint('👆 InkWell onTapDown detected for: ${event.title}');
        },
        onTapCancel: () {
          debugPrint('❌ InkWell onTapCancel for: ${event.title}');
        },
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
                      borderRadius: const BorderRadius.circular(DesignTokens.radius12),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.gray900,
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
                        borderRadius: const BorderRadius.circular(20),
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
 SizedBox(height: DesignTokens.space16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                  ),
                  child: Text(
                    event.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DesignTokens.gray600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              
 SizedBox(height: DesignTokens.space16),
              
              // Time and Status Row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryCoral.withOpacity(0.1),
                      borderRadius: const BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: DesignTokens.primaryCoral,
                        ),
 SizedBox(width: 6),
                        Text(
                          '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.primaryCoral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.circular(20),
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
 SizedBox(width: 6),
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
 SizedBox(height: DesignTokens.space16),
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
 SizedBox(height: 8),
          Text(
            'Yeni randevu oluşturmak için + butonuna tıklayın',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
 SizedBox(height: DesignTokens.space16),
          CustomButton(
            text: 'Randevu Oluştur',
            icon: Icon(Icons.add, size: 18),
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
          backgroundColor: DesignTokens.primaryCoral,
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
          return DesignTokens.primaryCoral;
        case 'accepted':
          return DesignTokens.primaryCoral;
        case 'in_progress':
          return DesignTokens.primaryCoral;
        case 'completed':
          return DesignTokens.success;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    } else {
      switch (status) {
        case 'pending':
          return DesignTokens.primaryCoral;
        case 'confirmed':
          return DesignTokens.success;
        case 'cancelled':
          return Colors.red;
        case 'completed':
          return DesignTokens.primaryCoral;
        default:
          return Colors.grey;
      }
    }
  }

  Color _getEventPriorityColor(String? priority) {
    switch (priority) {
      case 'low':
        return DesignTokens.primaryCoral;
      case 'normal':
        return DesignTokens.primaryCoral;
      case 'high':
        return DesignTokens.primaryCoral;
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
    debugPrint('🔥 _showEventDetails started for event: ${event.title}');
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          debugPrint('✅ Modal bottom sheet builder called');
          return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.circular(2),
              ),
            ),
            
            // Header with gradient
            Container(
              margin: EdgeInsets.all(DesignTokens.space16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: DesignTokens.primaryCoralGradient,
                borderRadius: const BorderRadius.circular(DesignTokens.radius16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                    ),
                    child: Icon(
                      event.isJob ? Icons.work_outline : Icons.event_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
 SizedBox(width: DesignTokens.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
 SizedBox(height: 4),
                        Text(
                          event.isJob ? 'İş Randevusu' : 'Etkinlik',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Info
                    _buildDetailCard(
                      icon: Icons.access_time_outlined,
                      title: 'Zaman',
                      content: '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                      color: DesignTokens.primaryCoral,
                    ),
                    
                    // Status Info
                    _buildDetailCard(
                      icon: Icons.info_outline,
                      title: 'Durum',
                      content: _getStatusText(event.status, event.isJob),
                      color: _getEventStatusColor(event.status, event.isJob),
                    ),
                    
                    // Location Info
                    if (event.location != null) ...[
                      _buildDetailCard(
                        icon: Icons.location_on_outlined,
                        title: 'Konum',
                        content: event.location!,
                        color: DesignTokens.primaryCoral,
                      ),
                    ],
                    
                    // Description
                    if (event.description != null) ...[
                      _buildDetailCard(
                        icon: Icons.description_outlined,
                        title: 'Açıklama',
                        content: event.description!,
                        color: DesignTokens.primaryCoral,
                      ),
                    ],
                    
                    // Priority (if job)
                    if (event.isJob && event.priority != null) ...[
                      _buildDetailCard(
                        icon: Icons.priority_high,
                        title: 'Öncelik',
                        content: _getPriorityText(event.priority!),
                        color: _getEventPriorityColor(event.priority),
                      ),
                    ],
                    
 SizedBox(height: 20),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Navigate to edit appointment
                            },
                            icon: Icon(Icons.edit_outlined),
                            label: Text('Düzenle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignTokens.primaryCoral,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                              ),
                            ),
                          ),
                        ),
 SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Cancel appointment
                            },
                            icon: Icon(Icons.cancel_outlined),
                            label: Text('İptal Et'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                              ),
                            ),
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
        },
      ).then((value) {
      debugPrint('✅ Modal bottom sheet closed');
    }).catchError((error) {
      debugPrint('❌ Modal bottom sheet error: $error');
    });
    debugPrint('✅ showModalBottomSheet call completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _showEventDetails: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Modal açılırken hata: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.circular(DesignTokens.radius12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.circular(DesignTokens.radius8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
 SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
 SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DesignTokens.gray900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}