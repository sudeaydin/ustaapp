import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/appointment_model.dart';

class CalendarState {
  final List<Appointment> appointments;
  final List<Appointment> upcomingAppointments;
  final List<Appointment> todayAppointments;
  final Map<DateTime, List<Appointment>> appointmentsByDate;
  final bool isLoading;
  final String? error;

  CalendarState({
    this.appointments = const [],
    this.upcomingAppointments = const [],
    this.todayAppointments = const [],
    this.appointmentsByDate = const {},
    this.isLoading = false,
    this.error,
  });

  CalendarState copyWith({
    List<Appointment>? appointments,
    List<Appointment>? upcomingAppointments,
    List<Appointment>? todayAppointments,
    Map<DateTime, List<Appointment>>? appointmentsByDate,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      appointments: appointments ?? this.appointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      appointmentsByDate: appointmentsByDate ?? this.appointmentsByDate,
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

  Future<void> loadUpcomingAppointments({int limit = 5}) async {
    try {
      final apiResponse = await ApiService.getInstance().get(
        '/calendar/appointments/upcoming',
        queryParams: {'limit': limit.toString()},
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
      final apiResponse = await ApiService.getInstance().get('/calendar/appointments/today');

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