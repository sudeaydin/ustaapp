import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
          // Calendar widget
          _buildCalendar(calendarState),
          
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<Appointment>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: (day) {
          final events = ref.read(calendar_provider.calendarProvider).eventsByDate[DateTime(day.year, day.month, day.day)] ?? [];
          // Convert events to appointments for TableCalendar compatibility
          return events.where((e) => e.isAppointment).map((e) => Appointment.fromJson(e.data)).toList();
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Colors.red[400]),
          holidayTextStyle: TextStyle(color: Colors.red[400]),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          formatButtonTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
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

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedDay != null 
                ? '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} - Etkinlikler'
                : 'Etkinlikler',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: selectedDayEvents.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.nonPhotoBlue.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bu tarihte etkinlik yok',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(selectedDayEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(calendar_provider.CalendarEvent event) {
    final isJob = event.isJob;
    final statusColor = _getEventStatusColor(event.status, isJob);
    final priorityColor = _getEventPriorityColor(event.priority);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showEventDetails(event);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: statusColor,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isJob ? Icons.work : Icons.event,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isJob && event.priority != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: priorityColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        _getPriorityText(event.priority!),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: priorityColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              if (event.description != null) ...[
                Text(
                  event.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(event.status, isJob),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (event.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              if (isJob && event.estimatedCost != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.estimatedCost!.toStringAsFixed(0)} ₺',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
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