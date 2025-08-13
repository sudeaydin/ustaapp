import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  
  // Stream controllers for real-time events
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _quoteController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _statusController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController = 
      StreamController<bool>.broadcast();
  final StreamController<Set<int>> _typingController = 
      StreamController<Set<int>>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get quoteStream => _quoteController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<Set<int>> get typingStream => _typingController.stream;

  // Current state
  bool get isConnected => _isConnected;
  final Set<int> _typingUsers = <int>{};

  Future<void> connect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null) {
        print('No auth token found, skipping socket connection');
        return;
      }

      _socket = IO.io(AppConfig.socketUrl, 
        IO.OptionBuilder()
          .setAuth({'token': token})
          .setTransports(['websocket', 'polling'])
          .setTimeout(20000)
          .setForceNew(true)
          .build()
      );

      _setupEventListeners();
      
    } catch (e) {
      print('Socket connection error: $e');
    }
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.on('connect', (_) {
      print('Socket.IO connected');
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);
    });

    _socket!.on('disconnect', (reason) {
      print('Socket.IO disconnected: $reason');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket!.on('connect_error', (error) {
      print('Socket.IO connection error: $error');
      _handleReconnect();
    });

    // Message events
    _socket!.on('new_message', (data) {
      print('New message received: $data');
      _messageController.add({
        'type': 'new_message',
        'data': data,
      });
    });

    _socket!.on('message_sent', (data) {
      _messageController.add({
        'type': 'message_sent',
        'data': data,
      });
    });

    _socket!.on('messages_read', (data) {
      _messageController.add({
        'type': 'messages_read',
        'data': data,
      });
    });

    // Typing events
    _socket!.on('user_typing', (data) {
      final userId = data['user_id'] as int;
      final isTyping = data['typing'] as bool;
      
      if (isTyping) {
        _typingUsers.add(userId);
      } else {
        _typingUsers.remove(userId);
      }
      
      _typingController.add(Set.from(_typingUsers));
    });

    // Quote events
    _socket!.on('new_quote_request', (data) {
      print('New quote request: $data');
      _quoteController.add({
        'type': 'new_quote_request',
        'data': data,
      });
    });

    _socket!.on('quote_updated', (data) {
      print('Quote updated: $data');
      _quoteController.add({
        'type': 'quote_updated',
        'data': data,
      });
    });

    _socket!.on('quote_broadcast', (data) {
      _quoteController.add({
        'type': 'quote_broadcast',
        'data': data,
      });
    });

    // Status events
    _socket!.on('user_status_changed', (data) {
      _statusController.add({
        'type': 'user_status_changed',
        'data': data,
      });
    });

    // Push notifications
    _socket!.on('push_notification', (data) {
      _handlePushNotification(data);
    });

    // Error handling
    _socket!.on('error', (data) {
      print('Socket.IO error: $data');
    });
  }

  void _handleReconnect() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(
        milliseconds: (1000 * (1 << _reconnectAttempts)).clamp(0, 30000)
      );
      
      print('Attempting to reconnect in ${delay.inMilliseconds}ms (attempt $_reconnectAttempts)');
      
      Timer(delay, () {
        if (_socket != null) {
          _socket!.connect();
        }
      });
    } else {
      print('Max reconnection attempts reached');
    }
  }

  void _handlePushNotification(Map<String, dynamic> data) {
    // Handle push notification display
    // In a real app, this would integrate with firebase_messaging
    print('Push notification: $data');
  }

  // Message methods
  void sendMessage(int recipientId, String content, {String type = 'text'}) {
    if (!_isConnected || _socket == null) {
      throw Exception('Socket not connected');
    }

    _socket!.emit('send_message', {
      'recipient_id': recipientId,
      'content': content,
      'type': type,
    });
  }

  void markMessagesRead(int senderId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('mark_messages_read', {
      'sender_id': senderId,
    });
  }

  void startTyping(int recipientId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('typing_start', {
      'recipient_id': recipientId,
    });
  }

  void stopTyping(int recipientId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('typing_stop', {
      'recipient_id': recipientId,
    });
  }

  // Conversation methods
  void joinConversation(int otherUserId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('join_conversation', {
      'other_user_id': otherUserId,
    });
  }

  void leaveConversation(int otherUserId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('leave_conversation', {
      'other_user_id': otherUserId,
    });
  }

  // Quote methods
  void updateQuoteStatus(int quoteId, String status) {
    if (!_isConnected || _socket == null) {
      throw Exception('Socket not connected');
    }

    _socket!.emit('quote_status_update', {
      'quote_id': quoteId,
      'status': status,
    });
  }

  // Location methods
  void updateLocation(double latitude, double longitude) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('craftsman_location_update', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  // Analytics methods
  void trackPageView(String page) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('page_view', {'page': page});
  }

  void trackUserAction(String action, {Map<String, dynamic>? details}) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('user_action', {
      'action': action,
      'details': details ?? {},
    });
  }

  // Admin methods
  void joinAdminDashboard() {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('join_admin_dashboard');
  }

  // Connection management
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _isConnected = false;
      _connectionController.add(false);
    }
  }

  void reconnect() {
    disconnect();
    Timer(const Duration(seconds: 1), () {
      connect();
    });
  }

  // Check if user is typing
  bool isUserTyping(int userId) {
    return _typingUsers.contains(userId);
  }

  // Get typing users list
  Set<int> getTypingUsers() {
    return Set.from(_typingUsers);
  }

  // Dispose method
  void dispose() {
    disconnect();
    _messageController.close();
    _quoteController.close();
    _statusController.close();
    _connectionController.close();
    _typingController.close();
  }
}

// Provider for Socket Service
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

// Connection status provider
final socketConnectionProvider = StreamProvider<bool>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.connectionStream;
});

// Messages stream provider
final socketMessagesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.messageStream;
});

// Quotes stream provider
final socketQuotesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.quoteStream;
});

// Typing users provider
final typingUsersProvider = StreamProvider<Set<int>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.typingStream;
});

// Online status provider
final onlineStatusProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.statusStream;
});