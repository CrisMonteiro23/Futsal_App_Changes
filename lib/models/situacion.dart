// lib/models/situacion.dart
class Situacion {
  String id;
  DateTime timestamp;
  bool esAFavor;
  String tipoLlegada;
  List<String> jugadoresEnCanchaIds;
  List<String> jugadoresEnCanchaNombres;

  Situacion({
    required this.id,
    required this.timestamp,
    required this.esAFavor,
    required this.tipoLlegada,
    required this.jugadoresEnCanchaIds,
    required this.jugadoresEnCanchaNombres,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'esAFavor': esAFavor,
      'tipoLlegada': tipoLlegada,
      'jugadoresEnCanchaIds': jugadoresEnCanchaIds,
      'jugadoresEnCanchaNombres': jugadoresEnCanchaNombres,
    };
  }

  factory Situacion.fromJson(Map<String, dynamic> json) {
    return Situacion(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      esAFavor: json['esAFavor'],
      tipoLlegada: json['tipoLlegada'],
      jugadoresEnCanchaIds: List<String>.from(json['jugadoresEnCanchaIds']),
      jugadoresEnCanchaNombres: List<String>.from(json['jugadoresEnCanchaNombres']),
    );
  }
}
