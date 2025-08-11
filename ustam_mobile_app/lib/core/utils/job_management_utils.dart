import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

/// Job status enumeration
enum JobStatus {
  pending,
  accepted,
  inProgress,
  paused,
  materialsNeeded,
  qualityCheck,
  completed,
  cancelled,
  disputed
}

/// Job priority enumeration
enum JobPriority {
  low,
  normal,
  high,
  urgent,
  emergency
}

/// Material status enumeration
enum MaterialStatus {
  planned,
  ordered,
  delivered,
  used,
  returned
}

/// Time entry type enumeration
enum TimeEntryType {
  work,
  travel,
  break_,
  materials,
  consultation
}

/// Warranty status enumeration
enum WarrantyStatus {
  active,
  expired,
  claimed,
  void_
}

/// Job model
class Job {
  final int id;
  final String title;
  final String? description;
  final int customerId;
  final int? craftsmanId;
  final int? quoteId;
  final JobStatus status;
  final JobPriority priority;
  final String category;
  final String? subcategory;
  final String? address;
  final String? city;
  final String? district;
  final double? latitude;
  final double? longitude;
  final double? estimatedCost;
  final double? finalCost;
  final double? materialsCost;
  final double? laborCost;
  final double? additionalCosts;
  final int? estimatedDuration;
  final int? actualDuration;
  final DateTime? scheduledStart;
  final DateTime? actualStart;
  final DateTime? scheduledEnd;
  final DateTime? actualEnd;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool isEmergency;
  final int? emergencyLevel;
  final String? emergencyContact;
  final String? emergencyNotes;
  final double? completionPercentage;
  final double? qualityScore;
  final int? customerSatisfaction;
  final String? specialRequirements;
  final List<String>? images;
  final List<String>? documents;
  final String? notes;
  final String? cancellationReason;
  final int warrantyPeriodMonths;
  final DateTime? warrantyStartDate;
  final DateTime? warrantyEndDate;
  final String? warrantyTerms;
  final WarrantyStatus? warrantyStatus;
  final bool isOverdue;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? craftsman;
  final List<JobMaterial>? materials;
  final List<TimeEntry>? timeEntries;
  final List<JobProgressUpdate>? progressUpdates;

  Job({
    required this.id,
    required this.title,
    this.description,
    required this.customerId,
    this.craftsmanId,
    this.quoteId,
    required this.status,
    required this.priority,
    required this.category,
    this.subcategory,
    this.address,
    this.city,
    this.district,
    this.latitude,
    this.longitude,
    this.estimatedCost,
    this.finalCost,
    this.materialsCost,
    this.laborCost,
    this.additionalCosts,
    this.estimatedDuration,
    this.actualDuration,
    this.scheduledStart,
    this.actualStart,
    this.scheduledEnd,
    this.actualEnd,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.isEmergency = false,
    this.emergencyLevel,
    this.emergencyContact,
    this.emergencyNotes,
    this.completionPercentage,
    this.qualityScore,
    this.customerSatisfaction,
    this.specialRequirements,
    this.images,
    this.documents,
    this.notes,
    this.cancellationReason,
    this.warrantyPeriodMonths = 12,
    this.warrantyStartDate,
    this.warrantyEndDate,
    this.warrantyTerms,
    this.warrantyStatus,
    this.isOverdue = false,
    this.customer,
    this.craftsman,
    this.materials,
    this.timeEntries,
    this.progressUpdates,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      customerId: json['customer_id'],
      craftsmanId: json['craftsman_id'],
      quoteId: json['quote_id'],
      status: _parseJobStatus(json['status']),
      priority: _parseJobPriority(json['priority']),
      category: json['category'],
      subcategory: json['subcategory'],
      address: json['address'],
      city: json['city'],
      district: json['district'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      estimatedCost: json['estimated_cost']?.toDouble(),
      finalCost: json['final_cost']?.toDouble(),
      materialsCost: json['materials_cost']?.toDouble(),
      laborCost: json['labor_cost']?.toDouble(),
      additionalCosts: json['additional_costs']?.toDouble(),
      estimatedDuration: json['estimated_duration'],
      actualDuration: json['actual_duration'],
      scheduledStart: json['scheduled_start'] != null ? DateTime.parse(json['scheduled_start']) : null,
      actualStart: json['actual_start'] != null ? DateTime.parse(json['actual_start']) : null,
      scheduledEnd: json['scheduled_end'] != null ? DateTime.parse(json['scheduled_end']) : null,
      actualEnd: json['actual_end'] != null ? DateTime.parse(json['actual_end']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      isEmergency: json['is_emergency'] ?? false,
      emergencyLevel: json['emergency_level'],
      emergencyContact: json['emergency_contact'],
      emergencyNotes: json['emergency_notes'],
      completionPercentage: json['completion_percentage']?.toDouble(),
      qualityScore: json['quality_score']?.toDouble(),
      customerSatisfaction: json['customer_satisfaction'],
      specialRequirements: json['special_requirements'],
      images: json['images']?.cast<String>(),
      documents: json['documents']?.cast<String>(),
      notes: json['notes'],
      cancellationReason: json['cancellation_reason'],
      warrantyPeriodMonths: json['warranty_period_months'] ?? 12,
      warrantyStartDate: json['warranty_start_date'] != null ? DateTime.parse(json['warranty_start_date']) : null,
      warrantyEndDate: json['warranty_end_date'] != null ? DateTime.parse(json['warranty_end_date']) : null,
      warrantyTerms: json['warranty_terms'],
      warrantyStatus: _parseWarrantyStatus(json['warranty_status']),
      isOverdue: json['is_overdue'] ?? false,
      customer: json['customer'],
      craftsman: json['craftsman'],
      materials: json['materials']?.map<JobMaterial>((m) => JobMaterial.fromJson(m))?.toList(),
      timeEntries: json['time_entries']?.map<TimeEntry>((t) => TimeEntry.fromJson(t))?.toList(),
      progressUpdates: json['progress_updates']?.map<JobProgressUpdate>((p) => JobProgressUpdate.fromJson(p))?.toList(),
    );
  }

  double get totalCost => (materialsCost ?? 0) + (laborCost ?? 0) + (additionalCosts ?? 0);
}

/// Job material model
class JobMaterial {
  final int id;
  final int jobId;
  final String name;
  final String? description;
  final String? category;
  final String? brand;
  final String? model;
  final double quantity;
  final String unit;
  final double? unitCost;
  final double? totalCost;
  final String? supplier;
  final String? supplierContact;
  final MaterialStatus status;
  final DateTime? orderedAt;
  final DateTime? expectedDelivery;
  final DateTime? deliveredAt;
  final DateTime? usedAt;
  final String? notes;
  final String? receiptUrl;
  final String? warrantyInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobMaterial({
    required this.id,
    required this.jobId,
    required this.name,
    this.description,
    this.category,
    this.brand,
    this.model,
    required this.quantity,
    required this.unit,
    this.unitCost,
    this.totalCost,
    this.supplier,
    this.supplierContact,
    required this.status,
    this.orderedAt,
    this.expectedDelivery,
    this.deliveredAt,
    this.usedAt,
    this.notes,
    this.receiptUrl,
    this.warrantyInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobMaterial.fromJson(Map<String, dynamic> json) {
    return JobMaterial(
      id: json['id'],
      jobId: json['job_id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      brand: json['brand'],
      model: json['model'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      unitCost: json['unit_cost']?.toDouble(),
      totalCost: json['total_cost']?.toDouble(),
      supplier: json['supplier'],
      supplierContact: json['supplier_contact'],
      status: _parseMaterialStatus(json['status']),
      orderedAt: json['ordered_at'] != null ? DateTime.parse(json['ordered_at']) : null,
      expectedDelivery: json['expected_delivery'] != null ? DateTime.parse(json['expected_delivery']) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
      notes: json['notes'],
      receiptUrl: json['receipt_url'],
      warrantyInfo: json['warranty_info'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Time entry model
class TimeEntry {
  final int id;
  final int jobId;
  final int craftsmanId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final TimeEntryType entryType;
  final String? description;
  final String? location;
  final double? hourlyRate;
  final int? billableDuration;
  final double? totalCost;
  final bool isBillable;
  final String? notes;
  final List<String>? images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? craftsman;

  TimeEntry({
    required this.id,
    required this.jobId,
    required this.craftsmanId,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    required this.entryType,
    this.description,
    this.location,
    this.hourlyRate,
    this.billableDuration,
    this.totalCost,
    this.isBillable = true,
    this.notes,
    this.images,
    required this.createdAt,
    required this.updatedAt,
    this.craftsman,
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      jobId: json['job_id'],
      craftsmanId: json['craftsman_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      durationMinutes: json['duration_minutes'],
      entryType: _parseTimeEntryType(json['entry_type']),
      description: json['description'],
      location: json['location'],
      hourlyRate: json['hourly_rate']?.toDouble(),
      billableDuration: json['billable_duration'],
      totalCost: json['total_cost']?.toDouble(),
      isBillable: json['is_billable'] ?? true,
      notes: json['notes'],
      images: json['images']?.cast<String>(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      craftsman: json['craftsman'],
    );
  }

  bool get isActive => endTime == null;
  
  Duration get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    } else {
      return DateTime.now().difference(startTime);
    }
  }
}

/// Job progress update model
class JobProgressUpdate {
  final int id;
  final int jobId;
  final int craftsmanId;
  final String title;
  final String? description;
  final double completionPercentage;
  final List<String>? images;
  final List<String>? videos;
  final bool isVisibleToCustomer;
  final DateTime createdAt;
  final Map<String, dynamic>? craftsman;

  JobProgressUpdate({
    required this.id,
    required this.jobId,
    required this.craftsmanId,
    required this.title,
    this.description,
    required this.completionPercentage,
    this.images,
    this.videos,
    this.isVisibleToCustomer = true,
    required this.createdAt,
    this.craftsman,
  });

  factory JobProgressUpdate.fromJson(Map<String, dynamic> json) {
    return JobProgressUpdate(
      id: json['id'],
      jobId: json['job_id'],
      craftsmanId: json['craftsman_id'],
      title: json['title'],
      description: json['description'],
      completionPercentage: json['completion_percentage'].toDouble(),
      images: json['images']?.cast<String>(),
      videos: json['videos']?.cast<String>(),
      isVisibleToCustomer: json['is_visible_to_customer'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      craftsman: json['craftsman'],
    );
  }
}

/// Warranty claim model
class WarrantyClaim {
  final int id;
  final int jobId;
  final int customerId;
  final int craftsmanId;
  final String title;
  final String description;
  final String? issueType;
  final String? severity;
  final String status;
  final String? resolution;
  final double? resolutionCost;
  final DateTime claimedAt;
  final DateTime? reviewedAt;
  final DateTime? resolvedAt;
  final List<String>? images;
  final List<String>? videos;
  final List<String>? documents;
  final String? customerNotes;
  final String? craftsmanResponse;
  final String? adminNotes;
  final bool isValid;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? craftsman;
  final Map<String, dynamic>? job;

  WarrantyClaim({
    required this.id,
    required this.jobId,
    required this.customerId,
    required this.craftsmanId,
    required this.title,
    required this.description,
    this.issueType,
    this.severity,
    required this.status,
    this.resolution,
    this.resolutionCost,
    required this.claimedAt,
    this.reviewedAt,
    this.resolvedAt,
    this.images,
    this.videos,
    this.documents,
    this.customerNotes,
    this.craftsmanResponse,
    this.adminNotes,
    this.isValid = true,
    this.customer,
    this.craftsman,
    this.job,
  });

  factory WarrantyClaim.fromJson(Map<String, dynamic> json) {
    return WarrantyClaim(
      id: json['id'],
      jobId: json['job_id'],
      customerId: json['customer_id'],
      craftsmanId: json['craftsman_id'],
      title: json['title'],
      description: json['description'],
      issueType: json['issue_type'],
      severity: json['severity'],
      status: json['status'],
      resolution: json['resolution'],
      resolutionCost: json['resolution_cost']?.toDouble(),
      claimedAt: DateTime.parse(json['claimed_at']),
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      images: json['images']?.cast<String>(),
      videos: json['videos']?.cast<String>(),
      documents: json['documents']?.cast<String>(),
      customerNotes: json['customer_notes'],
      craftsmanResponse: json['craftsman_response'],
      adminNotes: json['admin_notes'],
      isValid: json['is_valid'] ?? true,
      customer: json['customer'],
      craftsman: json['craftsman'],
      job: json['job'],
    );
  }
}

/// Emergency service model
class EmergencyService {
  final int id;
  final int customerId;
  final int? craftsmanId;
  final int? jobId;
  final String title;
  final String description;
  final String emergencyType;
  final int severity;
  final String address;
  final String city;
  final String? district;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String contactPhone;
  final String? alternativeContact;
  final String status;
  final DateTime requestedAt;
  final DateTime? assignedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final double? estimatedCost;
  final double? finalCost;
  final double? emergencyFee;
  final List<String>? images;
  final String? notes;
  final int? customerRating;
  final String? customerFeedback;
  final int? responseTimeMinutes;
  final bool isUrgent;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? craftsman;
  final Map<String, dynamic>? job;

  EmergencyService({
    required this.id,
    required this.customerId,
    this.craftsmanId,
    this.jobId,
    required this.title,
    required this.description,
    required this.emergencyType,
    required this.severity,
    required this.address,
    required this.city,
    this.district,
    this.latitude,
    this.longitude,
    this.contactName,
    required this.contactPhone,
    this.alternativeContact,
    required this.status,
    required this.requestedAt,
    this.assignedAt,
    this.arrivedAt,
    this.completedAt,
    this.estimatedCost,
    this.finalCost,
    this.emergencyFee,
    this.images,
    this.notes,
    this.customerRating,
    this.customerFeedback,
    this.responseTimeMinutes,
    this.isUrgent = false,
    this.customer,
    this.craftsman,
    this.job,
  });

  factory EmergencyService.fromJson(Map<String, dynamic> json) {
    return EmergencyService(
      id: json['id'],
      customerId: json['customer_id'],
      craftsmanId: json['craftsman_id'],
      jobId: json['job_id'],
      title: json['title'],
      description: json['description'],
      emergencyType: json['emergency_type'],
      severity: json['severity'],
      address: json['address'],
      city: json['city'],
      district: json['district'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      contactName: json['contact_name'],
      contactPhone: json['contact_phone'],
      alternativeContact: json['alternative_contact'],
      status: json['status'],
      requestedAt: DateTime.parse(json['requested_at']),
      assignedAt: json['assigned_at'] != null ? DateTime.parse(json['assigned_at']) : null,
      arrivedAt: json['arrived_at'] != null ? DateTime.parse(json['arrived_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      estimatedCost: json['estimated_cost']?.toDouble(),
      finalCost: json['final_cost']?.toDouble(),
      emergencyFee: json['emergency_fee']?.toDouble(),
      images: json['images']?.cast<String>(),
      notes: json['notes'],
      customerRating: json['customer_rating'],
      customerFeedback: json['customer_feedback'],
      responseTimeMinutes: json['response_time_minutes'],
      isUrgent: json['is_urgent'] ?? false,
      customer: json['customer'],
      craftsman: json['craftsman'],
      job: json['job'],
    );
  }
}

/// Job management service
class JobManagementService {
  static final JobManagementService _instance = JobManagementService._internal();
  factory JobManagementService() => _instance;
  JobManagementService._internal();

  final ApiService _apiService = ApiService();

  /// Get jobs for user
  Future<List<Job>> getJobs({
    String? userType,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      if (userType != null) params['user_type'] = userType;
      if (status != null) params['status'] = status;

      final response = await _apiService.get('/job-management/jobs', params: params);
      
      if (response.success && response.data['jobs'] != null) {
        return (response.data['jobs'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load jobs: $e');
    }
  }

  /// Get job detail
  Future<Map<String, dynamic>?> getJobDetail(int jobId) async {
    try {
      final response = await _apiService.get('/job-management/jobs/$jobId');
      
      if (response.success) {
        return response.data;
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to load job detail: $e');
    }
  }

  /// Update job
  Future<bool> updateJob(int jobId, Map<String, dynamic> updateData) async {
    try {
      final response = await _apiService.putWithOptions('/job-management/jobs/$jobId', body: updateData);
      return response.success;
    } catch (e) {
      throw Exception('Failed to update job: $e');
    }
  }

  /// Start time tracking
  Future<TimeEntry?> startTimeTracking(int jobId, {
    TimeEntryType entryType = TimeEntryType.work,
    String? description,
    String? location,
  }) async {
    try {
      final response = await _apiService.postWithOptions('/job-management/jobs/$jobId/time/start', body: {
        'entry_type': entryType.name,
        'description': description,
        'location': location,
      });
      
      if (response.success) {
        return TimeEntry.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to start time tracking: $e');
    }
  }

  /// End time tracking
  Future<bool> endTimeTracking(int entryId, {String? notes, List<String>? images}) async {
    try {
      final response = await _apiService.putWithOptions('/job-management/time-entries/$entryId/end', body: {
        'notes': notes,
        'images': images,
      });
      
      return response.success;
    } catch (e) {
      throw Exception('Failed to end time tracking: $e');
    }
  }

  /// Add material to job
  Future<JobMaterial?> addMaterial(int jobId, Map<String, dynamic> materialData) async {
    try {
      final response = await _apiService.postWithOptions('/job-management/jobs/$jobId/materials', body: materialData);
      
      if (response.success) {
        return JobMaterial.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to add material: $e');
    }
  }

  /// Update material status
  Future<bool> updateMaterialStatus(int materialId, MaterialStatus status, {String? notes}) async {
    try {
      final response = await _apiService.putWithOptions('/job-management/materials/$materialId/status', body: {
        'status': status.name,
        'notes': notes,
      });
      
      return response.success;
    } catch (e) {
      throw Exception('Failed to update material status: $e');
    }
  }

  /// Add progress update
  Future<JobProgressUpdate?> addProgressUpdate(int jobId, {
    required String title,
    String? description,
    required double completionPercentage,
    List<String>? images,
    List<String>? videos,
    bool isVisibleToCustomer = true,
  }) async {
    try {
      final response = await _apiService.postWithOptions('/job-management/jobs/$jobId/progress', body: {
        'title': title,
        'description': description,
        'completion_percentage': completionPercentage,
        'images': images,
        'videos': videos,
        'is_visible_to_customer': isVisibleToCustomer,
      });
      
      if (response.success) {
        return JobProgressUpdate.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to add progress update: $e');
    }
  }

  /// Create warranty claim
  Future<WarrantyClaim?> createWarrantyClaim(int jobId, {
    required String title,
    required String description,
    String? issueType,
    String? severity,
    List<String>? images,
    List<String>? videos,
    String? customerNotes,
  }) async {
    try {
      final response = await _apiService.postWithOptions('/job-management/jobs/$jobId/warranty-claim', body: {
        'title': title,
        'description': description,
        'issue_type': issueType,
        'severity': severity,
        'images': images,
        'videos': videos,
        'customer_notes': customerNotes,
      });
      
      if (response.success) {
        return WarrantyClaim.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to create warranty claim: $e');
    }
  }

  /// Get warranties
  Future<List<Job>> getWarranties(String userType) async {
    try {
      final response = await _apiService.get('/job-management/warranties', params: {
        'user_type': userType,
      });
      
      if (response.success) {
        return (response.data as List)
            .map((job) => Job.fromJson(job))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load warranties: $e');
    }
  }

  /// Create emergency request
  Future<EmergencyService?> createEmergencyRequest({
    required String title,
    required String description,
    required String emergencyType,
    required int severity,
    required String address,
    required String city,
    String? district,
    double? latitude,
    double? longitude,
    String? contactName,
    required String contactPhone,
    String? alternativeContact,
    List<String>? images,
  }) async {
    try {
      final response = await _apiService.postWithOptions('/job-management/emergency-services', body: {
        'title': title,
        'description': description,
        'emergency_type': emergencyType,
        'severity': severity,
        'address': address,
        'city': city,
        'district': district,
        'latitude': latitude,
        'longitude': longitude,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'alternative_contact': alternativeContact,
        'images': images,
      });
      
      if (response.success) {
        return EmergencyService.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to create emergency request: $e');
    }
  }

  /// Get nearby emergencies for craftsman
  Future<List<EmergencyService>> getNearbyEmergencies({double maxDistance = 50}) async {
    try {
      final response = await _apiService.get('/job-management/emergency-services/nearby', params: {
        'max_distance': maxDistance.toString(),
      });
      
      if (response.success) {
        return (response.data as List)
            .map((emergency) => EmergencyService.fromJson(emergency))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load nearby emergencies: $e');
    }
  }

  /// Assign emergency service
  Future<bool> assignEmergencyService(int emergencyId) async {
    try {
      final response = await _apiService.putWithOptions('/job-management/emergency-services/$emergencyId/assign', body: {});
      return response.success;
    } catch (e) {
      throw Exception('Failed to assign emergency service: $e');
    }
  }

  /// Get performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics(String userType, {int days = 30}) async {
    try {
      final response = await _apiService.get('/job-management/analytics/performance', params: {
        'user_type': userType,
        'days': days.toString(),
      });
      
      if (response.success) {
        return response.data;
      }
      
      return {};
    } catch (e) {
      throw Exception('Failed to load performance metrics: $e');
    }
  }
}

// Helper functions for parsing enums
JobStatus _parseJobStatus(String? status) {
  if (status == null) return JobStatus.pending;
  
  switch (status) {
    case 'pending': return JobStatus.pending;
    case 'accepted': return JobStatus.accepted;
    case 'in_progress': return JobStatus.inProgress;
    case 'paused': return JobStatus.paused;
    case 'materials_needed': return JobStatus.materialsNeeded;
    case 'quality_check': return JobStatus.qualityCheck;
    case 'completed': return JobStatus.completed;
    case 'cancelled': return JobStatus.cancelled;
    case 'disputed': return JobStatus.disputed;
    default: return JobStatus.pending;
  }
}

JobPriority _parseJobPriority(String? priority) {
  if (priority == null) return JobPriority.normal;
  
  switch (priority) {
    case 'low': return JobPriority.low;
    case 'normal': return JobPriority.normal;
    case 'high': return JobPriority.high;
    case 'urgent': return JobPriority.urgent;
    case 'emergency': return JobPriority.emergency;
    default: return JobPriority.normal;
  }
}

MaterialStatus _parseMaterialStatus(String? status) {
  if (status == null) return MaterialStatus.planned;
  
  switch (status) {
    case 'planned': return MaterialStatus.planned;
    case 'ordered': return MaterialStatus.ordered;
    case 'delivered': return MaterialStatus.delivered;
    case 'used': return MaterialStatus.used;
    case 'returned': return MaterialStatus.returned;
    default: return MaterialStatus.planned;
  }
}

TimeEntryType _parseTimeEntryType(String? type) {
  if (type == null) return TimeEntryType.work;
  
  switch (type) {
    case 'work': return TimeEntryType.work;
    case 'travel': return TimeEntryType.travel;
    case 'break': return TimeEntryType.break_;
    case 'materials': return TimeEntryType.materials;
    case 'consultation': return TimeEntryType.consultation;
    default: return TimeEntryType.work;
  }
}

WarrantyStatus _parseWarrantyStatus(String? status) {
  if (status == null) return WarrantyStatus.void_;
  
  switch (status) {
    case 'active': return WarrantyStatus.active;
    case 'expired': return WarrantyStatus.expired;
    case 'claimed': return WarrantyStatus.claimed;
    case 'void': return WarrantyStatus.void_;
    default: return WarrantyStatus.void_;
  }
}

// Extensions for enum display
extension JobStatusExtension on JobStatus {
  String get displayName {
    switch (this) {
      case JobStatus.pending: return 'Beklemede';
      case JobStatus.accepted: return 'Kabul Edildi';
      case JobStatus.inProgress: return 'Devam Ediyor';
      case JobStatus.paused: return 'Duraklatıldı';
      case JobStatus.materialsNeeded: return 'Malzeme Gerekli';
      case JobStatus.qualityCheck: return 'Kalite Kontrolü';
      case JobStatus.completed: return 'Tamamlandı';
      case JobStatus.cancelled: return 'İptal Edildi';
      case JobStatus.disputed: return 'Anlaşmazlık';
    }
  }

  Color get color {
    switch (this) {
      case JobStatus.pending: return Colors.orange;
      case JobStatus.accepted: return Colors.blue;
      case JobStatus.inProgress: return Colors.purple;
      case JobStatus.paused: return Colors.amber;
      case JobStatus.materialsNeeded: return Colors.red;
      case JobStatus.qualityCheck: return Colors.indigo;
      case JobStatus.completed: return Colors.green;
      case JobStatus.cancelled: return Colors.grey;
      case JobStatus.disputed: return Colors.red;
    }
  }
}

extension JobPriorityExtension on JobPriority {
  String get displayName {
    switch (this) {
      case JobPriority.low: return 'Düşük';
      case JobPriority.normal: return 'Normal';
      case JobPriority.high: return 'Yüksek';
      case JobPriority.urgent: return 'Acil';
      case JobPriority.emergency: return 'Acil Servis';
    }
  }

  String get icon {
    switch (this) {
      case JobPriority.low: return '🟢';
      case JobPriority.normal: return '🟡';
      case JobPriority.high: return '🟠';
      case JobPriority.urgent: return '🔴';
      case JobPriority.emergency: return '🚨';
    }
  }
}

extension MaterialStatusExtension on MaterialStatus {
  String get displayName {
    switch (this) {
      case MaterialStatus.planned: return 'Planlandı';
      case MaterialStatus.ordered: return 'Sipariş Edildi';
      case MaterialStatus.delivered: return 'Teslim Alındı';
      case MaterialStatus.used: return 'Kullanıldı';
      case MaterialStatus.returned: return 'İade Edildi';
    }
  }

  Color get color {
    switch (this) {
      case MaterialStatus.planned: return Colors.grey;
      case MaterialStatus.ordered: return Colors.orange;
      case MaterialStatus.delivered: return Colors.blue;
      case MaterialStatus.used: return Colors.green;
      case MaterialStatus.returned: return Colors.red;
    }
  }
}

extension TimeEntryTypeExtension on TimeEntryType {
  String get displayName {
    switch (this) {
      case TimeEntryType.work: return 'Çalışma';
      case TimeEntryType.travel: return 'Seyahat';
      case TimeEntryType.break_: return 'Mola';
      case TimeEntryType.materials: return 'Malzeme';
      case TimeEntryType.consultation: return 'Danışmanlık';
    }
  }

  String get icon {
    switch (this) {
      case TimeEntryType.work: return '🔧';
      case TimeEntryType.travel: return '🚗';
      case TimeEntryType.break_: return '☕';
      case TimeEntryType.materials: return '📦';
      case TimeEntryType.consultation: return '💬';
    }
  }
}

/// Job management constants
class JobManagementConstants {
  static const List<String> materialUnits = [
    'piece', 'meter', 'kg', 'liter', 'square_meter', 'cubic_meter',
    'hour', 'day', 'box', 'bag', 'roll', 'bottle', 'can'
  ];

  static const Map<String, String> materialUnitDisplayNames = {
    'piece': 'Adet',
    'meter': 'Metre',
    'kg': 'Kilogram',
    'liter': 'Litre',
    'square_meter': 'Metrekare',
    'cubic_meter': 'Metreküp',
    'hour': 'Saat',
    'day': 'Gün',
    'box': 'Kutu',
    'bag': 'Torba',
    'roll': 'Rulo',
    'bottle': 'Şişe',
    'can': 'Teneke'
  };

  static const List<String> emergencyTypes = [
    'plumbing', 'electrical', 'hvac', 'security', 'structural', 'other'
  ];

  static const Map<String, String> emergencyTypeDisplayNames = {
    'plumbing': 'Tesisatçı',
    'electrical': 'Elektrikçi',
    'hvac': 'Isıtma/Soğutma',
    'security': 'Güvenlik',
    'structural': 'Yapısal',
    'other': 'Diğer'
  };

  static const List<String> issueSeverities = [
    'low', 'medium', 'high', 'critical'
  ];

  static const Map<String, String> issueSeverityDisplayNames = {
    'low': 'Düşük',
    'medium': 'Orta',
    'high': 'Yüksek',
    'critical': 'Kritik'
  };
}