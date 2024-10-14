import 'package:app_a3/screens/tarefas/tarefa_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tarefa.dart';
import '../../providers/tarefa_provider.dart';
import '../../providers/auth_provider.dart';

class TarefasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final tarefaProvider = context.watch<TarefaProvider>();

    if (authProvider.usuario == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Center(child: CircularProgressIndicator());
    }

    final usuarioId = authProvider.usuario!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas tarefas'),
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
        future: tarefaProvider.listaTarefas(usuarioId!),
        builder: (context, snapshot) {
          if (tarefaProvider.tarefas.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa encontrada'));
          }

          return ListView.builder(
            itemCount: tarefaProvider.tarefas.length,
            itemBuilder: (context, index) {
              Tarefa tarefa = tarefaProvider.tarefas[index];
              return ListTile(
                title: Text(tarefa.titulo),
                subtitle: Text(tarefa.descricao),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return TarefaModal(tarefa: tarefa);
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await tarefaProvider.excluiTarefa(tarefa.id!);
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
              return TarefaModal();
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
