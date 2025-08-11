class Review {
  final int id;
  final int customerId;
  final int craftsmanId;
  final int quoteId;
  final int rating;
  final String? title;
  final String? comment;
  final int? qualityRating;
  final int? punctualityRating;
  final int? communicationRating;
  final int? cleanlinessRating;
  final List<String> images;
  final bool isVerified;
  final bool isVisible;
  final String? craftsmanResponse;
  final DateTime? responseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Customer? customer;
  final Service? service;

  Review({
    required this.id,
    required this.customerId,
    required this.craftsmanId,
    required this.quoteId,
    required this.rating,
    this.title,
    this.comment,
    this.qualityRating,
    this.punctualityRating,
    this.communicationRating,
    this.cleanlinessRating,
    this.images = const [],
    this.isVerified = false,
    this.isVisible = true,
    this.craftsmanResponse,
    this.responseDate,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.service,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      customerId: json['customer_id'],
      craftsmanId: json['craftsman_id'],
      quoteId: json['quote_id'],
      rating: json['rating'],
      title: json['title'],
      comment: json['comment'],
      qualityRating: json['quality_rating'],
      punctualityRating: json['punctuality_rating'],
      communicationRating: json['communication_rating'],
      cleanlinessRating: json['cleanliness_rating'],
      images: List<String>.from(json['images'] ?? []),
      isVerified: json['is_verified'] ?? false,
      isVisible: json['is_visible'] ?? true,
      craftsmanResponse: json['craftsman_response'],
      responseDate: json['response_date'] != null 
          ? DateTime.parse(json['response_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customer: json['customer'] != null 
          ? Customer.fromJson(json['customer']) 
          : null,
      service: json['service'] != null 
          ? Service.fromJson(json['service']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'craftsman_id': craftsmanId,
      'quote_id': quoteId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'quality_rating': qualityRating,
      'punctuality_rating': punctualityRating,
      'communication_rating': communicationRating,
      'cleanliness_rating': cleanlinessRating,
      'images': images,
      'is_verified': isVerified,
      'is_visible': isVisible,
      'craftsman_response': craftsmanResponse,
      'response_date': responseDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get averageRating {
    final ratings = [
      qualityRating,
      punctualityRating,
      communicationRating,
      cleanlinessRating,
    ].where((r) => r != null).cast<int>().toList();

    if (ratings.isNotEmpty) {
      return ratings.reduce((a, b) => a + b) / ratings.length;
    }
    return rating.toDouble();
  }
}

class Customer {
  final int id;
  final User user;

  Customer({
    required this.id,
    required this.user,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String firstName;
  final String lastName;
  final String? profileImage;

  User({
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class Service {
  final int id;
  final String title;
  final Category? category;

  Service({
    required this.id,
    required this.title,
    this.category,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title'],
      category: json['category'] != null 
          ? Category.fromJson(json['category']) 
          : null,
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ReviewStatistics {
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution;

  ReviewStatistics({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
  });

  factory ReviewStatistics.fromJson(Map<String, dynamic> json) {
    final stats = json['statistics'];
    final distribution = Map<int, int>.from(
      stats['rating_distribution'].map((key, value) => 
        MapEntry(int.parse(key.split('_')[0]), value as int)
      )
    );

    return ReviewStatistics(
      totalReviews: stats['total_reviews'],
      averageRating: (stats['average_rating'] as num).toDouble(),
      ratingDistribution: distribution,
    );
  }
}