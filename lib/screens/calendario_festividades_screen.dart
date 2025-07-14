import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/festividad.dart';
import '../models/provincia.dart';
import '../models/canton.dart';
import '../models/recordatorio.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarioFestividadesScreen extends StatefulWidget {
  const CalendarioFestividadesScreen({super.key});

  @override
  State<CalendarioFestividadesScreen> createState() =>
      _CalendarioFestividadesScreenState();
}

class _CalendarioFestividadesScreenState
    extends State<CalendarioFestividadesScreen> {
  final ApiService apiService = ApiService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Canton? _cantoneseleccionada;
  List<Canton> _cantones = [];
  Map<DateTime, List<Festividad>> _eventos = {};
  Map<DateTime, List<Recordatorio>> _recordatorios = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _cargarCantones();
    _cargarRecordatorios();
  }

  Future<void> _cargarCantones() async {
    final data = await apiService.obtenerCantones();
    setState(() {
      _cantones = data;
      if (_cantones.isNotEmpty) {
        _cantoneseleccionada = _cantones.first;
        _cargarEventos();
      }
    });
  }

  Future<void> _cargarEventos() async {
    if (_cantoneseleccionada == null) return;
    final data = await apiService.obtenerFestividadesPorCanton(
      _cantoneseleccionada!.id,
    );

    final unicos = <String, Festividad>{};
    for (var fest in data) {
      unicos['${fest.nombre}-${fest.fecha}'] = fest;
    }

    final agrupados = <DateTime, List<Festividad>>{};
    for (var fest in unicos.values) {
      final dt = DateTime.tryParse(fest.fecha);
      if (dt != null) {
        final key = DateTime(dt.year, dt.month, dt.day);
        agrupados.putIfAbsent(key, () => []).add(fest);
      }
    }

    setState(() => _eventos = agrupados);
  }
  //Logout agregado

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _cargarRecordatorios() async {
    final data = await apiService.obtenerRecordatorios();
    final agrupados = <DateTime, List<Recordatorio>>{};
    for (var rec in data) {
      final dt = DateTime.tryParse(rec.fechaHora);
      if (dt != null) {
        final key = DateTime(dt.year, dt.month, dt.day);
        agrupados.putIfAbsent(key, () => []).add(rec);
      }
    }
    setState(() => _recordatorios = agrupados);
  }

  /// Une ambos mapas de eventos y recordatorios para los marcadores
  List<dynamic> _getMarcadores(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return [...?_eventos[key], ...?_recordatorios[key]];
  }

  void _mostrarDialogoRecordatorio({Recordatorio? editable}) {
    final tituloCtrl = TextEditingController(text: editable?.titulo);
    final mensajeCtrl = TextEditingController(text: editable?.mensaje);
    DateTime fechaHora =
        editable != null
            ? DateTime.parse(editable.fechaHora)
            : (_selectedDay ?? DateTime.now());

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              editable != null ? 'Editar Recordatorio' : 'Nuevo Recordatorio',
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Título (opcional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: mensajeCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Mensaje (opcional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    DateFormat('yyyy-MM-dd – HH:mm').format(fechaHora),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: fechaHora,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026),
                      builder:
                          (ctx, child) =>
                              Theme(data: ThemeData.dark(), child: child!),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(fechaHora),
                        builder:
                            (ctx, child) =>
                                Theme(data: ThemeData.dark(), child: child!),
                      );
                      if (time != null) {
                        fechaHora = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (editable == null) {
                    await apiService.crearRecordatorio(
                      titulo:
                          tituloCtrl.text.isEmpty
                              ? null
                              : tituloCtrl.text.trim(),
                      mensaje:
                          mensajeCtrl.text.isEmpty
                              ? null
                              : mensajeCtrl.text.trim(),
                      fechaHora: fechaHora.toIso8601String(),
                      festividadId: null,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📥 Recordatorio creado con éxito'),
                      ),
                    );
                  } else {
                    await apiService.actualizarRecordatorio(
                      Recordatorio(
                        id: editable.id,
                        titulo: tituloCtrl.text.trim(),
                        mensaje: mensajeCtrl.text.trim(),
                        fechaHora: fechaHora.toIso8601String(),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✏️ Recordatorio actualizado'),
                      ),
                    );
                  }
                  _cargarRecordatorios();
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventos =
        _eventos[DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        )] ??
        [];
    final recs =
        _recordatorios[DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        )] ??
        [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Calendario de Festividades',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // — Dropdown de provincias —
            DropdownButton<Canton>(
              dropdownColor: Colors.black87,
              value: _cantoneseleccionada,
              isExpanded: true,
              style: const TextStyle(color: Colors.white),
              underline: Container(height: 1, color: Colors.white24),
              items:
                  _cantones
                      .map(
                        (prov) => DropdownMenuItem(
                          value: prov,
                          child: Text(prov.nombre),
                        ),
                      )
                      .toList(),
              onChanged: (n) {
                setState(() {
                  _cantoneseleccionada = n;
                  _cargarEventos();
                });
              },
            ),

            const SizedBox(height: 12),

            // — Calendario —
            Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar<dynamic>(
                locale: 'es_ES',
                firstDay: DateTime(2025, 1, 1),
                lastDay: DateTime(2025, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                onDaySelected: (sel, foc) {
                  setState(() {
                    _selectedDay = sel;
                    _focusedDay = foc;
                  });
                },
                eventLoader: _getMarcadores,

                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextFormatter: (date, locale) {
                    final t = DateFormat.yMMMM(locale).format(date);
                    return t[0].toUpperCase() + t.substring(1);
                  },
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                  titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueGrey.shade700,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.white70),
                  outsideTextStyle: const TextStyle(color: Colors.white30),
                  // quitamos markerDecoration aquí
                  markersMaxCount: 1,
                  markersAlignment: Alignment.bottomCenter,
                ),

                // ← Aquí diferenciamos rojo/azul
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return null;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          events.map((e) {
                            final color =
                                e is Recordatorio
                                    ? Colors.blueAccent
                                    : Colors.red;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            );
                          }).toList(),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // — Festividades —
            if (eventos.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '🎉 Festividades',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              for (var fest in eventos)
                ListTile(
                  tileColor: Colors.black54,
                  leading: const Icon(Icons.celebration, color: Colors.white),
                  title: Text(
                    fest.nombre,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    fest.descripcion,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // — Recordatorios —
            if (recs.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '🔔 Recordatorios',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              for (var rec in recs)
                ListTile(
                  tileColor: Colors.black54,
                  leading: const Icon(Icons.alarm, color: Colors.white),
                  title: Text(
                    rec.titulo ?? 'Sin título',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    rec.mensaje ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed:
                            () => _mostrarDialogoRecordatorio(editable: rec),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text(
                                    '¿Eliminar recordatorio?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                          if (ok == true) {
                            await apiService.eliminarRecordatorio(rec.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '🗑️ Recordatorio eliminado con éxito',
                                ),
                              ),
                            );
                            _cargarRecordatorios();
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],

            // — Si no hay nada —
            if (eventos.isEmpty && recs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'No hay festividades ni recordatorios',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogoRecordatorio(),
      ),
    );
  }
}
