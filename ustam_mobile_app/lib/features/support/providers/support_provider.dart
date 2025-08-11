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
      final apiResponse = await ApiService.getInstance().post('/support/tickets', {
        'subject': subject,
        'description': description,
        'category': category,
        'priority': priority,
      });

      if (apiResponse.isSuccess) {
        // Reload tickets
        await loadUserTickets();
        return true;
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Destek talebi oluşturulamadı',
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
      final apiResponse = await ApiService.getInstance().get('/support/tickets');

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final tickets = List<Map<String, dynamic>>.from(
          apiResponse.data!['tickets'] ?? []
        );
        
        state = state.copyWith(
          tickets: tickets,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Destek talepleri getirilemedi',
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
      final apiResponse = await ApiService.getInstance().get('/support/tickets/$ticketId');

      if (apiResponse.isSuccess && apiResponse.data != null) {
        state = state.copyWith(
          currentTicket: apiResponse.data!,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Destek talebi detayları getirilemedi',
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
      final apiResponse = await ApiService.getInstance().post('/support/tickets/$ticketId/messages', {
        'message': message,
      });

      if (apiResponse.isSuccess) {
        // Reload ticket detail to get updated messages
        await loadTicketDetail(ticketId);
        return true;
      } else {
        state = state.copyWith(
          error: apiResponse.error?.userFriendlyMessage ?? 'Mesaj gönderilemedi',
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