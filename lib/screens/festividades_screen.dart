import 'package:flutter/material.dart';
import '../models/festividad.dart';
import '../models/provincia.dart';
import '../models/canton.dart';
import '../services/api_service.dart';

class FestividadesScreen extends StatefulWidget {
  final Canton canton;

  const FestividadesScreen({Key? key, required this.canton}) : super(key: key);

  @override
  State<FestividadesScreen> createState() => _FestividadesScreenState();
}

class _FestividadesScreenState extends State<FestividadesScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Festividad>> _festividadesFuture;

  @override
  void initState() {
    super.initState();
    _festividadesFuture = apiService.obtenerFestividadesPorCanton(widget.canton.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Festividades en ${widget.canton.nombre}'),
      ),
      body: FutureBuilder<List<Festividad>>(
        future: _festividadesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay festividades registradas.'));
          }

          final festividades = snapshot.data!;
          festividades.sort((a, b) => a.fecha.compareTo(b.fecha));

          return ListView.builder(
            itemCount: festividades.length,
            itemBuilder: (context, index) {
              final fest = festividades[index];
              final fecha = DateTime.tryParse(fest.fecha);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: fecha != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${fecha.day}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('${_getMonthName(fecha.month)}', style: const TextStyle(fontSize: 12)),
                          ],
                        )
                      : const Icon(Icons.event),
                  title: Text(fest.nombre),
                  subtitle: Text(fest.descripcion),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return meses[month - 1];
  }
}
