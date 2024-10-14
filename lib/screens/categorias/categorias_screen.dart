import 'package:app_a3/providers/categoria_provider.dart';
import 'package:app_a3/screens/categorias/categoria_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/categoria.dart';
import '../../providers/auth_provider.dart';

class CategoriasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final categoriaProvider = context.watch<CategoriaProvider>();

    if (authProvider.usuario == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Center(child: CircularProgressIndicator());
    }

    final usuarioId = authProvider.usuario!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas categorias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: categoriaProvider.listaCategorias(usuarioId!),
        builder: (context, snapshot) {
          if (categoriaProvider.categorias.isEmpty) {
            return const Center(child: Text('Nenhuma categoria encontrada'));
          }

          return ListView.builder(
            itemCount: categoriaProvider.categorias.length,
            itemBuilder: (context, index) {
              Categoria categoria = categoriaProvider.categorias[index];
              return ListTile(
                title: Text(categoria.nome),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return CategoriaModal(categoria: categoria);
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await categoriaProvider.excluiCategoria(categoria.id!);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return CategoriaModal();
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
