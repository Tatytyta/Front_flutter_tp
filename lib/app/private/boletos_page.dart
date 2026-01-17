import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../src/lib/token_storage.dart';
import '../../src/lib/datasources/crud_service.dart';
import '../../src/config/api_constants.dart';
import '../../domain/entities/boleto.dart';

class BoletosPage extends StatefulWidget {
  const BoletosPage({super.key});

  @override
  State<BoletosPage> createState() => _BoletosPageState();
}

class _BoletosPageState extends State<BoletosPage> {
  late final CrudService<Boleto> _boletoService;
  List<Boleto> _boletos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _boletoService = CrudService<Boleto>(
      endpoint: ApiConstants.boletosEndpoint,
      fromJson: (json) => Boleto.fromJson(json),
      client: http.Client(),
      tokenStorage: TokenStorage(),
      requiresAuth: true,
    );
    _loadBoletos();
  }

  Future<void> _loadBoletos() async {
    setState(() => _loading = true);
    try {
      final response = await _boletoService.getAll();
      setState(() {
        _boletos = response.results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar boletos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Boletos'),
        backgroundColor: const Color(0xFF27ae60),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBoletos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _boletos.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 100,
                          color: Color(0xFF95a5a6),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'No tienes boletos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tus boletos comprados aparecerán aquí',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBoletos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _boletos.length,
                    itemBuilder: (context, index) {
                      final boleto = _boletos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: const Icon(
                              Icons.confirmation_number,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'Boleto #${boleto.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Viaje: #${boleto.viaje}'),
                              Text('Monto: \$${double.tryParse(boleto.monto)?.toStringAsFixed(2) ?? boleto.monto}'),
                              () {
                                try {
                                  final fecha = DateTime.parse(boleto.fechaCompra);
                                  return Text(
                                    'Comprado: ${fecha.day}/${fecha.month}/${fecha.year}',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                } catch (e) {
                                  return Text(
                                    'Comprado: ${boleto.fechaCompra}',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                }
                              }(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
