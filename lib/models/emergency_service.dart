class EmergencyService {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final double rating;
  final String? logoUrl;

  EmergencyService({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.rating,
    this.logoUrl,
  });

  // Factory constructor to convert JSON to Dart Object
  factory EmergencyService.fromJson(Map<String, dynamic> json) {
    return EmergencyService(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      rating: (json['rating'] as num).toDouble(),
      logoUrl: json['logoUrl'],
    );
  }
}
