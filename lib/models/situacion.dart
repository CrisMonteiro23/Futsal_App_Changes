class Situacion {
  String id;
  DateTime timestamp;
  bool esAFavor;
  String tipoLlegada;
  List<String> jugadoresEnCanchaIds;
  List<String> jugadoresEnCanchaNombres;

  // ➕ Nuevos campos opcionales
  String? jugadorClaveId;       // ID del jugador que perdió o recuperó la pelota
  String? tipoAccionClave;      // "Pérdida" o "Recuperación"

  Situacion({
    required this.id,
    required this.timestamp,
    required this.esAFavor,
    required this.tipoLlegada,
    required this.jugadoresEnCanchaIds,
    required this.jugadoresEnCanchaNombres,
    this.jugadorClaveId,
    this.tipoAccionClave,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'esAFavor': esAFavor,
      'tipoLlegada': tipoLlegada,
      'jugadoresEnCanchaIds': jugadoresEnCanchaIds,
      'jugadoresEnCanchaNombres': jugadoresEnCanchaNombres,
      'jugadorClaveId': jugadorClaveId,
      'tipoAccionClave': tipoAccionClave,
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
      jugadorClaveId: json['jugadorClaveId'],
      tipoAccionClave: json['tipoAccionClave'],
    );
  }
}
