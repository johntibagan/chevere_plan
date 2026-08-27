/// Resultado de búsqueda / reverse geocode / autocomplete / Place Details.
class GeoPlace {
  const GeoPlace({
    required this.lat,
    required this.lng,
    this.displayName,
    this.name,
    this.city,
    this.department,
    this.addressLine,
    this.placeId,
    this.isPlaceFicha = false,
  });

  final double lat;
  final double lng;
  final String? displayName;
  final String? name;
  final String? city;
  final String? department;
  final String? addressLine;
  final String? placeId;

  /// True si viene de ficha de lugar (Autocomplete / Details / Nearby).
  /// False = solo pin / reverse de calle. Preferir ficha al guardar (`use_exact_pin`).
  final bool isPlaceFicha;

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'displayName': displayName,
        'name': name,
        'city': city,
        'department': department,
        'addressLine': addressLine,
        'placeId': placeId,
        'isPlaceFicha': isPlaceFicha,
      };

  factory GeoPlace.fromJson(Map<String, dynamic> json) {
    return GeoPlace(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      displayName: json['displayName'] as String?,
      name: json['name'] as String?,
      city: json['city'] as String?,
      department: json['department'] as String?,
      addressLine: json['addressLine'] as String?,
      placeId: json['placeId'] as String?,
      isPlaceFicha: json['isPlaceFicha'] as bool? ?? false,
    );
  }

  GeoPlace copyWith({
    double? lat,
    double? lng,
    String? displayName,
    String? name,
    String? city,
    String? department,
    String? addressLine,
    String? placeId,
    bool? isPlaceFicha,
  }) {
    return GeoPlace(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      displayName: displayName ?? this.displayName,
      name: name ?? this.name,
      city: city ?? this.city,
      department: department ?? this.department,
      addressLine: addressLine ?? this.addressLine,
      placeId: placeId ?? this.placeId,
      isPlaceFicha: isPlaceFicha ?? this.isPlaceFicha,
    );
  }
}

/// Sugerencia de Autocomplete (aún sin coords; requiere Place Details).
class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.primaryText,
    this.secondaryText,
  });

  final String placeId;
  final String primaryText;
  final String? secondaryText;
}
