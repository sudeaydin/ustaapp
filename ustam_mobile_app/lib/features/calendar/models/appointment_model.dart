import 'package:flutter/material.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

enum AppointmentType {
  consultation,
  work,
  followUp,
  emergency,
}

class Appointment {
  final int id;
  final int customerId;
  final int craftsmanId;
  final int? quoteId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final AppointmentType type;
  final String? location;
  final String? notes;
  final bool isAllDay;
  final String? reminderTime; // e.g., "30 minutes", "1 hour"
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related data
  final Customer? customer;
  final Craftsman? craftsman;
  final Quote? quote;

  Appointment({
    required this.id,
    required this.customerId,
    required this.craftsmanId,
    this.quoteId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.type,
    this.location,
    this.notes,
    this.isAllDay = false,
    this.reminderTime,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.craftsman,
    this.quote,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      customerId: json['customer_id'],
      craftsmanId: json['craftsman_id'],
      quoteId: json['quote_id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      type: AppointmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppointmentType.consultation,
      ),
      location: json['location'],
      notes: json['notes'],
      isAllDay: json['is_all_day'] ?? false,
      reminderTime: json['reminder_time'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customer: json['customer'] != null 
          ? Customer.fromJson(json['customer']) 
          : null,
      craftsman: json['craftsman'] != null 
          ? Craftsman.fromJson(json['craftsman']) 
          : null,
      quote: json['quote'] != null 
          ? Quote.fromJson(json['quote']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'craftsman_id': craftsmanId,
      'quote_id': quoteId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.name,
      'type': type.name,
      'location': location,
      'notes': notes,
      'is_all_day': isAllDay,
      'reminder_time': reminderTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Duration get duration => endTime.difference(startTime);

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startTime.year == tomorrow.year &&
        startTime.month == tomorrow.month &&
        startTime.day == tomorrow.day;
  }

  bool get isPast => endTime.isBefore(DateTime.now());
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isActive => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);

  Color get statusColor {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.inProgress:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.rescheduled:
        return Colors.purple;
    }
  }

  String get statusText {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Beklemede';
      case AppointmentStatus.confirmed:
        return 'Onaylandı';
      case AppointmentStatus.inProgress:
        return 'Devam Ediyor';
      case AppointmentStatus.completed:
        return 'Tamamlandı';
      case AppointmentStatus.cancelled:
        return 'İptal Edildi';
      case AppointmentStatus.rescheduled:
        return 'Ertelendi';
    }
  }

  String get typeText {
    switch (type) {
      case AppointmentType.consultation:
        return 'Görüşme';
      case AppointmentType.work:
        return 'İş';
      case AppointmentType.followUp:
        return 'Takip';
      case AppointmentType.emergency:
        return 'Acil';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case AppointmentType.consultation:
        return Icons.chat;
      case AppointmentType.work:
        return Icons.build;
      case AppointmentType.followUp:
        return Icons.follow_the_signs;
      case AppointmentType.emergency:
        return Icons.emergency;
    }
  }
}

class Customer {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? profileImage;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.profileImage,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      profileImage: json['profile_image'],
    );
  }
}

class Craftsman {
  final int id;
  final String name;
  final String? businessName;
  final String? phone;
  final String? email;
  final String? profileImage;

  Craftsman({
    required this.id,
    required this.name,
    this.businessName,
    this.phone,
    this.email,
    this.profileImage,
  });

  factory Craftsman.fromJson(Map<String, dynamic> json) {
    return Craftsman(
      id: json['id'],
      name: json['name'],
      businessName: json['business_name'],
      phone: json['phone'],
      email: json['email'],
      profileImage: json['profile_image'],
    );
  }
}

class Quote {
  final int id;
  final String title;
  final double? price;
  final String status;

  Quote({
    required this.id,
    required this.title,
    this.price,
    required this.status,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      title: json['title'],
      price: json['price']?.toDouble(),
      status: json['status'],
    );
  }
}

class CalendarEvent {
  final DateTime date;
  final List<Appointment> appointments;

  CalendarEvent({
    required this.date,
    required this.appointments,
  });

  bool get hasAppointments => appointments.isNotEmpty;
  int get appointmentCount => appointments.length;
  
  List<Appointment> get confirmedAppointments =>
      appointments.where((a) => a.status == AppointmentStatus.confirmed).toList();
  
  List<Appointment> get pendingAppointments =>
      appointments.where((a) => a.status == AppointmentStatus.pending).toList();
}