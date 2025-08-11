import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class SupportState {
  final bool isLoading;
  final List<Map<String, dynamic>> tickets;
  final Map<String, dynamic>? currentTicket;
  final String? error;

  const SupportState({
    this.isLoading = false,
    this.tickets = const [],
    this.currentTicket,
    this.error,
  });

  SupportState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? tickets,
    Map<String, dynamic>? currentTicket,
    String? error,
  }) {
    return SupportState(
      isLoading: isLoading ?? this.isLoading,
      tickets: tickets ?? this.tickets,
      currentTicket: currentTicket ?? this.currentTicket,
      error: error ?? this.error,
    );
  }
}

class SupportNotifier extends StateNotifier<SupportState> {
  SupportNotifier() : super(const SupportState());

  Future<bool> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiService.post('/support/tickets', {
        'subject': subject,
        'description': description,
        'category': category,
        'priority': priority,
      });

      if (response['success'] == true) {
        // Reload tickets
        await loadUserTickets();
        return true;
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Destek talebi oluşturulamadı',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Destek talebi oluşturulurken hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> loadUserTickets() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiService.get('/support/tickets');

      if (response['success'] == true) {
        final tickets = List<Map<String, dynamic>>.from(
          response['data']['tickets'] ?? []
        );
        
        state = state.copyWith(
          tickets: tickets,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Destek talepleri getirilemedi',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Destek talepleri getirilirken hata oluştu',
        isLoading: false,
      );
    }
  }

  Future<bool> loadTicketDetail(int ticketId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiService.get('/support/tickets/$ticketId');

      if (response['success'] == true) {
        state = state.copyWith(
          currentTicket: response['data'],
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Destek talebi detayları getirilemedi',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Destek talebi detayları getirilirken hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> addMessage(int ticketId, String message) async {
    try {
      final response = await ApiService.post('/support/tickets/$ticketId/messages', {
        'message': message,
      });

      if (response['success'] == true) {
        // Reload ticket detail to get updated messages
        await loadTicketDetail(ticketId);
        return true;
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Mesaj gönderilemedi',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Mesaj gönderilirken hata oluştu',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final supportProvider = StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  return SupportNotifier();
});