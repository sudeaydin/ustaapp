import '../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum ErrorType {
  network,
  authentication,
  validation,
  server,
  unknown,
  timeout,
  noInternet,
}

class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  final int? statusCode;
  final dynamic originalError;

  const AppError({
    required this.type,
    required this.message,
    this.details,
    this.statusCode,
    this.originalError,
  });

  factory AppError.fromHttpResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      return AppError(
        type: _getErrorTypeFromStatusCode(response.statusCode),
        message: data['message'] ?? 'Bir hata oluştu',
        details: data['details']?.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AppError(
        type: ErrorType.server,
        message: 'Sunucu hatası (${response.statusCode})',
        statusCode: response.statusCode,
        originalError: e,
      );
    }
  }

  factory AppError.fromException(dynamic exception) {
    if (exception.toString().contains('SocketException')) {
      return const AppError(
        type: ErrorType.noInternet,
        message: 'İnternet bağlantınızı kontrol edin',
      );
    }
    
    if (exception.toString().contains('TimeoutException')) {
      return const AppError(
        type: ErrorType.timeout,
        message: 'İstek zaman aşımına uğradı',
      );
    }

    return AppError(
      type: ErrorType.unknown,
      message: 'Beklenmeyen bir hata oluştu',
      originalError: exception,
    );
  }

  static ErrorType _getErrorTypeFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return ErrorType.validation;
      case 401:
      case 403:
        return ErrorType.authentication;
      case 404:
        return ErrorType.server;
      case 500:
      case 502:
      case 503:
        return ErrorType.server;
      default:
        return ErrorType.unknown;
    }
  }

  String get userFriendlyMessage {
    switch (type) {
      case ErrorType.network:
        return 'Ağ bağlantısı sorunu yaşanıyor';
      case ErrorType.authentication:
        return 'Oturum süreniz dolmuş, lütfen tekrar giriş yapın';
      case ErrorType.validation:
        return message;
      case ErrorType.server:
        return 'Sunucu hatası, lütfen daha sonra tekrar deneyin';
      case ErrorType.timeout:
        return 'İstek zaman aşımına uğradı, lütfen tekrar deneyin';
      case ErrorType.noInternet:
        return 'İnternet bağlantınızı kontrol edin';
      case ErrorType.unknown:
        return 'Beklenmeyen bir hata oluştu';
    }
  }

  IconData get icon {
    switch (type) {
      case ErrorType.network:
      case ErrorType.noInternet:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.server:
        return Icons.error;
      case ErrorType.timeout:
        return Icons.timer;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }

  Color get color {
    switch (type) {
      case ErrorType.network:
      case ErrorType.noInternet:
        return DesignTokens.warning;
      case ErrorType.authentication:
        return DesignTokens.error;
      case ErrorType.validation:
        return DesignTokens.warning;
      case ErrorType.server:
        return DesignTokens.error;
      case ErrorType.timeout:
        return DesignTokens.warning;
      case ErrorType.unknown:
        return DesignTokens.textMuted;
    }
  }
}

class ErrorHandler {
  static void showError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(error.icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.userFriendlyMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: error.color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
        ),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: DesignTokens.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
        ),
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: DesignTokens.warning,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
        ),
      ),
    );
  }
}

// Error state widgets
class ErrorStateWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: error.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                error.icon,
                size: 40,
                color: error.color,
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            Text(
              error.userFriendlyMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: DesignTokens.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            if (error.details != null) ...[
              const SizedBox(height: 8),
              Text(
                error.details!,
                style: TextStyle(
                  fontSize: 14,
                  color: DesignTokens.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: DesignTokens.space24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryCoral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radius12),
                  ),
                ),
                child: Text(retryText ?? 'Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DesignTokens.nonPhotoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: DesignTokens.textMuted,
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokens.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: DesignTokens.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: DesignTokens.space24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryCoral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radius12),
                  ),
                ),
                child: Text(actionText ?? 'Başla'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}