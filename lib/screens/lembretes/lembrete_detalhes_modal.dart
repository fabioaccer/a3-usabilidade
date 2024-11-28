import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lembrete.dart';
import '../../providers/tarefa_provider.dart';
import '../../models/tarefa.dart';

class LembreteDetalhesModal extends StatelessWidget {
  final Lembrete lembrete;

  const LembreteDetalhesModal({super.key, required this.lembrete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detalhes do Lembrete',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Título', lembrete.titulo),
                _buildDetailRow('Descrição', lembrete.descricao),
                _buildDetailRow('Data', lembrete.data),
                _buildDetailRow('Hora', lembrete.hora),
                if (lembrete.tarefaId != null) _buildTarefaDetails(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTarefaDetails(BuildContext context) {
    return Consumer<TarefaProvider>(
      builder: (context, tarefaProvider, _) {
        final tarefa = tarefaProvider.tarefas
            .where((t) => t.id == lembrete.tarefaId)
            .firstOrNull;

        if (tarefa == null) {
          return _buildDetailRow('Tarefa', 'Tarefa não encontrada');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Tarefa Relacionada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Título', tarefa.titulo),
                  _buildDetailRow('Status', tarefa.realizada ? 'Realizada' : 'Pendente'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
