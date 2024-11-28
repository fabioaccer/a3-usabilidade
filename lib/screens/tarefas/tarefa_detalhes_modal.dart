import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tarefa.dart';
import '../../providers/categoria_provider.dart';

class TarefaDetalhesModal extends StatelessWidget {
  final Tarefa tarefa;

  const TarefaDetalhesModal({super.key, required this.tarefa});

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
                    Text(
                      'Detalhes da Tarefa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Título', tarefa.titulo),
                _buildDetailRow('Descrição', tarefa.descricao),
                _buildDetailRow('Data', tarefa.data),
                _buildDetailRow('Hora', tarefa.hora),
                _buildDetailRow('Categoria', _getCategoriaName(context)),
                _buildDetailRow('Status', tarefa.realizada ? 'Realizada' : 'Pendente'),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoriaName(BuildContext context) {
    if (tarefa.categoriaId == null) return 'Sem categoria';

    final categoriaProvider = Provider.of<CategoriaProvider>(context, listen: false);
    final categoria = categoriaProvider.categorias
        .where((cat) => cat.id == tarefa.categoriaId)
        .firstOrNull;

    return categoria?.nome ?? 'Categoria não encontrada';
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
