import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/calendar_provider.dart';
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
    
    // Load appointments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarProvider.notifier).loadAppointments();
      ref.read(calendarProvider.notifier).loadUpcomingAppointments();
      ref.read(calendarProvider.notifier).loadTodayAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Takvim',
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

  Widget _buildCalendar(CalendarState calendarState) {
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
        eventLoader: (day) => ref.read(calendarProvider.notifier).getAppointmentsForDate(day),
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

  Widget _buildAppointmentsList(CalendarState calendarState) {
    if (calendarState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (calendarState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              calendarState.error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Tekrar Dene',
              onPressed: () {
                ref.read(calendarProvider.notifier).loadAppointments();
              },
            ),
          ],
        ),
      );
    }

    final selectedDayAppointments = _selectedDay != null
        ? ref.read(calendarProvider.notifier).getAppointmentsForDate(_selectedDay!)
        : <Appointment>[];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected day header
          Row(
            children: [
              Icon(
                Icons.event,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedDay != null
                    ? _formatSelectedDay(_selectedDay!)
                    : 'Randevular',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${selectedDayAppointments.length} randevu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Appointments list
          Expanded(
            child: selectedDayAppointments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: selectedDayAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = selectedDayAppointments[index];
                      return AppointmentCard(
                        appointment: appointment,
                        userType: widget.userType,
                        onTap: () => _showAppointmentDetail(appointment),
                        onStatusChanged: (newStatus) => _updateAppointmentStatus(appointment, newStatus),
                      );
                    },
                  ),
          ),
        ],
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
          ref.read(calendarProvider.notifier).loadAppointments();
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
    final success = await ref.read(calendarProvider.notifier).updateAppointment(
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
      final error = ref.read(calendarProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Randevu güncellenemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}