import 'package:app_a3/providers/lembrete_provider.dart';
import 'package:app_a3/screens/lembretes/lembrete_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lembrete.dart';
import '../../providers/auth_provider.dart';

class LembretesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final lembreteProvider = context.watch<LembreteProvider>();

    if (authProvider.usuario == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Center(child: CircularProgressIndicator());
    }

    final usuarioId = authProvider.usuario!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus lembretes'),
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
        future: lembreteProvider.listaLembretes(usuarioId!),
        builder: (context, snapshot) {
          if (lembreteProvider.lembretes.isEmpty) {
            return const Center(child: Text('Nenhum lembrete encontrado'));
          }

          return ListView.builder(
            itemCount: lembreteProvider.lembretes.length,
            itemBuilder: (context, index) {
              Lembrete lembrete = lembreteProvider.lembretes[index];
              return ListTile(
                title: Text(lembrete.titulo),
                subtitle: Text(lembrete.descricao),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return LembreteModal(lembrete: lembrete);
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await lembreteProvider.excluiLembrete(lembrete.id!);
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
              return LembreteModal();
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
