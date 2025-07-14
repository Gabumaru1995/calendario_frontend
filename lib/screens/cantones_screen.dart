import 'package:flutter/material.dart';
import '../models/provincia.dart';
import '../models/canton.dart';
import '../services/api_service.dart';
import 'festividades_screen.dart';


class CantonesScreen extends StatefulWidget {
  const CantonesScreen({Key? key}) : super(key: key);

  @override
  State<CantonesScreen> createState() => _CantonesScreenState();
}

class _CantonesScreenState extends State<CantonesScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Canton>> _cantonesFuture;

  @override
  void initState() {
    super.initState();
    _cantonesFuture = apiService.obtenerCantones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cantones del Ecuador')),
      body: FutureBuilder<List<Canton>>(
        future: _cantonesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay cantones disponibles.'));
          }

          final cantones = snapshot.data!;

          return ListView.builder(
            itemCount: cantones.length,
            itemBuilder: (context, index) {
              final canton = cantones[index];
              return ListTile(
                title: Text(canton.nombre),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FestividadesScreen(canton: canton),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
