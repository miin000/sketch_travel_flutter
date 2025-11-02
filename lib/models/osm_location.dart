class OsmLocation {
  final String displayName;
  final double lat;
  final double lon;
  final String city;
  final String country;

  OsmLocation({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.city,
    required this.country,
  });

  // Tên địa điểm chính (ví dụ: "Vịnh Hạ Long" thay vì "Vịnh Hạ Long, Thành phố Hạ Long, ...")
  String get name => displayName.split(',')[0];

  factory OsmLocation.fromJson(Map<String, dynamic> json) {
    // Lấy thông tin địa chỉ, fallback nếu không có
    final address = json['address'] as Map<String, dynamic>? ?? {};

    return OsmLocation(
      displayName: json['display_name'] ?? 'Không rõ tên',
      lat: double.tryParse(json['lat'] ?? '0.0') ?? 0.0,
      lon: double.tryParse(json['lon'] ?? '0.0') ?? 0.0,
      city: address['city'] ?? address['state'] ?? '',
      country: address['country'] ?? '',
    );
  }
}