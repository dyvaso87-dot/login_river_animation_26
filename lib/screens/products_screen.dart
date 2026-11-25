import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  static const String baseUrl = 'http://localhost:8090';

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      }
      throw Exception('La respuesta no es una lista de productos');
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('No hay productos registrados'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index] as Map<String, dynamic>;
final nombre = item['nombre'] ?? item['name'] ?? 'Sin nombre';
final codigo = item['codigoBarras'] ?? item['codigo_barras'] ?? item['barcode'] ?? '';
final precio = item['precioVenta'] ?? item['precio_venta'] ?? item['price'] ?? '';

              return ListTile(
                title: Text(nombre.toString()),
                subtitle: Text('Código: $codigo'),
                trailing: Text('\$$precio'),
              );
            },
          );
        },
      ),
    );
  }
}