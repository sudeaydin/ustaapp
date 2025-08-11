import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/appointment_model.dart';

class CalendarEvent {
  final String id;
  final String type; // 'appointment' or 'job'
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? location;
  final String? category;
  final String? priority;
  final double? estimatedCost;
  final Map<String, dynamic> data;

  CalendarEvent({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.location,
    this.category,
    this.priority,
    this.estimatedCost,
    required this.data,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'].toString(),
      type: json['type'] ?? 'appointment',
      title: json['title'] ?? '',
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: json['status'] ?? '',
      location: json['location'],
      category: json['category'],
      priority: json['priority'],
      estimatedCost: json['estimated_cost']?.toDouble(),
      data: json['data'] ?? {},
    );
  }

  bool get isJob => type == 'job';
  bool get isAppointment => type == 'appointment';
}

class CalendarState {
  final List<Appointment> appointments;
  final List<CalendarEvent> events;
  final List<Appointment> upcomingAppointments;
  final List<Appointment> todayAppointments;
  final Map<DateTime, List<Appointment>> appointmentsByDate;
  final Map<DateTime, List<CalendarEvent>> eventsByDate;
  final bool isLoading;
  final String? error;

  CalendarState({
    this.appointments = const [],
    this.events = const [],
    this.upcomingAppointments = const [],
    this.todayAppointments = const [],
    this.appointmentsByDate = const {},
    this.eventsByDate = const {},
    this.isLoading = false,
    this.error,
  });

  CalendarState copyWith({
    List<Appointment>? appointments,
    List<CalendarEvent>? events,
    List<Appointment>? upcomingAppointments,
    List<Appointment>? todayAppointments,
    Map<DateTime, List<Appointment>>? appointmentsByDate,
    Map<DateTime, List<CalendarEvent>>? eventsByDate,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      appointments: appointments ?? this.appointments,
      events: events ?? this.events,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      appointmentsByDate: appointmentsByDate ?? this.appointmentsByDate,
      eventsByDate: eventsByDate ?? this.eventsByDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(CalendarState());

  Future<void> loadAppointments({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final apiResponse = await ApiService.getInstance().get(
        '/calendar/appointments',
        queryParams: queryParams,
        requiresAuth: true,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final appointments = List<Appointment>.from(
          apiResponse.data!['appointments']?.map((json) => Appointment.fromJson(json)) ?? []
        );

        // Group appointments by date
        final appointmentsByDate = <DateTime, List<Appointment>>{};
        for (final appointment in appointments) {
          final date = DateTime(
            appointment.startTime.year,
            appointment.startTime.month,
            appointment.startTime.day,
          );
          appointmentsByDate.putIfAbsent(date, () => []);
          appointmentsByDate[date]!.add(appointment);
        }

        state = state.copyWith(
          appointments: appointments,
          appointmentsByDate: appointmentsByDate,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Randevular getirilemedi',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Randevular yüklenirken hata oluştu',
        isLoading: false,
      );
    }
  }

  Future<void> loadEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final apiResponse = await ApiService.getInstance().get(
        '/calendar/events',
        queryParams: queryParams,
        requiresAuth: true,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final events = List<CalendarEvent>.from(
          apiResponse.data!['events']?.map((json) => CalendarEvent.fromJson(json)) ?? []
        );

        // Group events by date
        final eventsByDate = <DateTime, List<CalendarEvent>>{};
        for (final event in events) {
          final date = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          );
          eventsByDate.putIfAbsent(date, () => []);
          eventsByDate[date]!.add(event);
        }

        state = state.copyWith(
          events: events,
          eventsByDate: eventsByDate,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Takvim etkinlikleri getirilemedi',
          isLoading: false,
        );
      }
    } catch (e) {
      String errorMessage = 'Takvim etkinlikleri yüklenirken hata oluştu';
      
      // Provide more specific error messages
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Failed host lookup')) {
        errorMessage = 'Backend sunucusu çalışmıyor. Lütfen sunucuyu başlatın.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'İstek zaman aşımına uğradı';
      }
      
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
    }
  }

  Future<void> loadUpcomingAppointments({int limit = 5}) async {
    try {
      final apiResponse = await ApiService.getInstance().get(
        '/calendar/appointments/upcoming',
        queryParams: {'limit': limit.toString()},
        requiresAuth: true,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final upcomingAppointments = List<Appointment>.from(
          apiResponse.data!.map((json) => Appointment.fromJson(json)) ?? []
        );

        state = state.copyWith(upcomingAppointments: upcomingAppointments);
      }
    } catch (e) {
      // Upcoming appointments are optional, don't show error
    }
  }

  Future<void> loadTodayAppointments() async {
    try {
      final apiResponse = await ApiService.getInstance().get(
        '/calendar/appointments/today',
        requiresAuth: true,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final todayAppointments = List<Appointment>.from(
          apiResponse.data!.map((json) => Appointment.fromJson(json)) ?? []
        );

        state = state.copyWith(todayAppointments: todayAppointments);
      }
    } catch (e) {
      // Today appointments are optional, don't show error
    }
  }

  Future<bool> createAppointment({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required int craftsmanId,
    int? customerId,
    int? quoteId,
    String? description,
    String? location,
    String? notes,
    AppointmentType type = AppointmentType.consultation,
    bool isAllDay = false,
    String? reminderTime,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiResponse = await ApiService.getInstance().post('/calendar/appointments', {
        'title': title,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'craftsman_id': craftsmanId,
        'customer_id': customerId,
        'quote_id': quoteId,
        'description': description,
        'location': location,
        'notes': notes,
        'type': type.name,
        'is_all_day': isAllDay,
        'reminder_time': reminderTime,
      });

      if (apiResponse.isSuccess) {
        // Reload appointments
        await loadAppointments();
        await loadUpcomingAppointments();
        await loadTodayAppointments();
        return true;
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Randevu oluşturulamadı',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Randevu oluşturulurken hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> updateAppointment({
    required int appointmentId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    String? location,
    String? notes,
    AppointmentStatus? status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (startTime != null) updateData['start_time'] = startTime.toIso8601String();
      if (endTime != null) updateData['end_time'] = endTime.toIso8601String();
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status.name;

      final apiResponse = await ApiService.getInstance().put(
        '/calendar/appointments/$appointmentId',
        updateData,
      );

      if (apiResponse.isSuccess) {
        // Reload appointments
        await loadAppointments();
        await loadUpcomingAppointments();
        await loadTodayAppointments();
        return true;
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Randevu güncellenemedi',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Randevu güncellenirken hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiResponse = await ApiService.getInstance().delete('/calendar/appointments/$appointmentId');

      if (apiResponse.isSuccess) {
        // Reload appointments
        await loadAppointments();
        await loadUpcomingAppointments();
        await loadTodayAppointments();
        return true;
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Randevu iptal edilemedi',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Randevu iptal edilirken hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  List<Appointment> getAppointmentsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return state.appointmentsByDate[dateKey] ?? [];
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});