import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mi_app_futsal/models/jugador.dart';
import 'package:mi_app_futsal/models/situacion.dart';

class AppData extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  // Lista de jugadores disponibles
  final List<Jugador> _jugadoresDisponibles = [
    Jugador(id: const Uuid().v4(), nombre: 'Victor'),
    Jugador(id: const Uuid().v4(), nombre: 'Fabio'),
    Jugador(id: const Uuid().v4(), nombre: 'Pablo'),
    Jugador(id: const Uuid().v4(), nombre: 'Nacho'),
    Jugador(id: const Uuid().v4(), nombre: 'Hugo'),
    Jugador(id: const Uuid().v4(), nombre: 'Carlos'),
    Jugador(id: const Uuid().v4(), nombre: 'Zequi'),
    Jugador(id: const Uuid().v4(), nombre: 'Arnaldo'),
    Jugador(id: const Uuid().v4(), nombre: 'Aranda'),
    Jugador(id: const Uuid().v4(), nombre: 'Enzo'),
    Jugador(id: const Uuid().v4(), nombre: 'Murilo'),
    Jugador(id: const Uuid().v4(), nombre: 'Titi'),
    Jugador(id: const Uuid().v4(), nombre: 'Pescio'),
    Jugador(id: const Uuid().v4(), nombre: 'Nicolas'),
  ];

  final List<Situacion> _situacionesRegistradas = [];

  // Ejemplo mapa de acciones clave (ID -> nombre), modifícalo según tu origen de datos
  final Map<String, String> _accionesClaveMap = {
    'accion1': 'Gol',
    'accion2': 'Asistencia',
    'accion3': 'Recuperación',
    'accion4': 'Pérdida',
    'accion5': 'Tiro al arco',
    // Añade aquí todas las acciones clave que uses con sus IDs
  };

  // Getter público para acceder a la lista de jugadores
  List<Jugador> get jugadores => List.unmodifiable(_jugadoresDisponibles);

  // Getter para uso directo (estadísticas)
  List<Jugador> get jugadoresDisponibles => _jugadoresDisponibles;

  List<Situacion> get situacionesRegistradas => List.unmodifiable(_situacionesRegistradas);

  void addJugador(String nombre) {
    if (nombre.trim().isEmpty) return;
    if (_jugadoresDisponibles.any((j) => j.nombre.toLowerCase() == nombre.toLowerCase())) return;
    _jugadoresDisponibles.add(Jugador(id: _uuid.v4(), nombre: nombre.trim()));
    notifyListeners();
  }

  // ✅ MODIFICADO: addSituacion ahora permite opcionalmente registrar jugadorClave y tipoAccionClave
  void addSituacion(
    bool esAFavor,
    String tipoLlegada,
    List<Jugador> jugadoresEnCancha, {
    String? jugadorClaveId,
    String? tipoAccionClave,
  }) {
    final situacion = Situacion(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      esAFavor: esAFavor,
      tipoLlegada: tipoLlegada,
      jugadoresEnCanchaIds: jugadoresEnCancha.map((j) => j.id).toList(),
      jugadoresEnCanchaNombres: jugadoresEnCancha.map((j) => j.nombre).toList(),
      jugadorClaveId: jugadorClaveId,
      tipoAccionClave: tipoAccionClave,
    );
    _situacionesRegistradas.add(situacion);
    notifyListeners();
  }

  void deleteSituacion(String id) {
    _situacionesRegistradas.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Devuelve las estadísticas por jugador incluyendo info de jugadorClave y accionClave para ese jugador
  /// Cambia la estructura para que incluya estos datos:
  ///
  /// Map<jugadorId, {
  ///   'favor': int,
  ///   'contra': int,
  ///   'jugadorClave': String? (jugadorClaveId más frecuente o null),
  ///   'accionClave': String? (tipoAccionClave más frecuente o null)
  /// }>
  Map<String, Map<String, dynamic>> getPlayerStats() {
    final Map<String, Map<String, dynamic>> stats = {};

    // Inicializar estructura
    for (var jugador in _jugadoresDisponibles) {
      stats[jugador.id] = {
        'favor': 0,
        'contra': 0,
        'jugadoresClaveFrecuentes': <String, int>{},
        'accionesClaveFrecuentes': <String, int>{},
      };
    }

    // Contar
    for (var situacion in _situacionesRegistradas) {
      for (var jugadorId in situacion.jugadoresEnCanchaIds) {
        final playerStat = stats.putIfAbsent(jugadorId, () {
          return {
            'favor': 0,
            'contra': 0,
            'jugadoresClaveFrecuentes': <String, int>{},
            'accionesClaveFrecuentes': <String, int>{},
          };
        });

        if (situacion.esAFavor) {
          playerStat['favor'] = (playerStat['favor'] as int) + 1;
        } else {
          playerStat['contra'] = (playerStat['contra'] as int) + 1;
        }

        // Registrar jugador clave para este jugador
        final claveId = situacion.jugadorClaveId;
        if (claveId != null && claveId.isNotEmpty) {
          final Map<String, int> jugadoresClave = playerStat['jugadoresClaveFrecuentes'] as Map<String, int>;
          jugadoresClave[claveId] = (jugadoresClave[claveId] ?? 0) + 1;
        }

        // Registrar accion clave para este jugador
        final accionId = situacion.tipoAccionClave;
        if (accionId != null && accionId.isNotEmpty) {
          final Map<String, int> accionesClave = playerStat['accionesClaveFrecuentes'] as Map<String, int>;
          accionesClave[accionId] = (accionesClave[accionId] ?? 0) + 1;
        }
      }
    }

    // Ahora determinar jugadorClave y accionClave más frecuentes para cada jugador
    for (var entry in stats.entries) {
      final playerStat = entry.value;
      final Map<String, int> jugClaveFreq = playerStat['jugadoresClaveFrecuentes'] ?? {};
      final Map<String, int> accClaveFreq = playerStat['accionesClaveFrecuentes'] ?? {};

      String? jugadorClaveId;
      String? accionClaveId;

      if (jugClaveFreq.isNotEmpty) {
        jugadorClaveId = jugClaveFreq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }

      if (accClaveFreq.isNotEmpty) {
        accionClaveId = accClaveFreq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }

      playerStat['jugadorClave'] = jugadorClaveId;
      playerStat['accionClave'] = accionClaveId;

      // Limpiar maps de frecuencias para no enviar a la UI
      playerStat.remove('jugadoresClaveFrecuentes');
      playerStat.remove('accionesClaveFrecuentes');
    }

    return stats;
  }

  Map<String, Map<String, int>> getSituacionTypeStats() {
    final Map<String, Map<String, int>> stats = {};

    for (var tipo in [
      'Ataque Posicional', 'INC Portero', 'Transicion Corta',
      'Transicion Larga', 'ABP', '5x4', '4x5', 'Dobles-Penales'
    ]) {
      stats[tipo] = {'favor': 0, 'contra': 0};
    }

    for (var situacion in _situacionesRegistradas) {
      stats.putIfAbsent(situacion.tipoLlegada, () => {'favor': 0, 'contra': 0});
      if (situacion.esAFavor) {
        stats[situacion.tipoLlegada]!['favor'] = stats[situacion.tipoLlegada]!['favor']! + 1;
      } else {
        stats[situacion.tipoLlegada]!['contra'] = stats[situacion.tipoLlegada]!['contra']! + 1;
      }
    }

    return stats;
  }

  // Totales reales (llegadas únicas, no duplicadas por jugador)
  Map<String, int> getTotalesReales() {
    final int favor = _situacionesRegistradas.where((s) => s.esAFavor).length;
    final int contra = _situacionesRegistradas.where((s) => !s.esAFavor).length;
    final int total = favor + contra;
    return {
      'favor': favor,
      'contra': contra,
      'total': total,
    };
  }

  // Nuevo: devuelve el nombre del jugador por id o null si no existe
  String? getNombreJugadorPorId(String? id) {
    if (id == null) return null;
    try {
      return _jugadoresDisponibles.firstWhere((j) => j.id == id).nombre;
    } catch (_) {
      return null;
    }
  }

  // Nuevo: devuelve el nombre de la acción clave por id o null si no existe
  String? getNombreAccionClave(String? id) {
    if (id == null) return null;
    return _accionesClaveMap[id];
  }
}
