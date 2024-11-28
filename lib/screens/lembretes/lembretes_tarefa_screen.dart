import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tarefa.dart';
import '../../models/lembrete.dart';
import '../../providers/lembrete_provider.dart';
import '../../providers/auth_provider.dart';
import 'lembrete_modal.dart';

class LembretesTarefaScreen extends StatefulWidget {
  final Tarefa tarefa;

  const LembretesTarefaScreen({Key? key, required this.tarefa}) : super(key: key);

  @override
  State<LembretesTarefaScreen> createState() => _LembretesTarefaScreenState();
}

class _LembretesTarefaScreenState extends State<LembretesTarefaScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregaLembretes();
  }

  Future<void> _carregaLembretes() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lembreteProvider = Provider.of<LembreteProvider>(context, listen: false);

    await lembreteProvider.listaLembretesPorTarefa(
        authProvider.usuario!.id!, widget.tarefa.id!);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lembreteProvider = context.watch<LembreteProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
        title: Text('Lembretes - ${widget.tarefa.titulo}'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : lembreteProvider.lembretes.isEmpty
                    ? const Center(
                        child: Text('Nenhum lembrete encontrado'),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregaLembretes,
                        child: ListView.builder(
                          itemCount: lembreteProvider.lembretes.length,
                          itemBuilder: (context, index) {
                            final lembrete = lembreteProvider.lembretes[index];
                            final isExpirado = lembrete.isExpirado();

                            return Opacity(
                              opacity: isExpirado ? 0.5 : 1.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Card(
                                  elevation: 0,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(
                                      lembrete.titulo,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${lembrete.data} às ${lembrete.hora}'),
                                      ],
                                    ),
                                    trailing: isExpirado ? null : PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text('Editar'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 20),
                                              SizedBox(width: 8),
                                              Text('Excluir'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 'edit':
                                            await _mostraModalLembrete(context,
                                                lembrete: lembrete);
                                            break;
                                          case 'delete':
                                            final confirma = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Excluir lembrete'),
                                                content: const Text(
                                                    'Tem certeza que deseja excluir este lembrete?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, false),
                                                    child: const Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, true),
                                                    child: const Text('Excluir'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirma == true) {
                                              final lembreteProvider =
                                                  Provider.of<LembreteProvider>(context,
                                                      listen: false);

                                              await lembreteProvider
                                                  .deletaLembrete(lembrete.id!);
                                              await _carregaLembretes();
                                            }
                                            break;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostraModalLembrete(context),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _mostraModalLembrete(BuildContext context,
      {Lembrete? lembrete}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LembreteModal(
        lembrete: lembrete,
      ),
    );

    if (result == true) {
      await _carregaLembretes();
    }
  }

  void _mostraDetalhesLembrete(BuildContext context, Lembrete lembrete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Lembrete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título: ${lembrete.titulo}'),
            const SizedBox(height: 8),
            Text('Descrição: ${lembrete.descricao}'),
            const SizedBox(height: 8),
            Text('Data: ${lembrete.data}'),
            const SizedBox(height: 8),
            Text('Hora: ${lembrete.hora}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
