import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tarefa.dart';
import '../../providers/tarefa_provider.dart';
import '../../providers/auth_provider.dart';

class TarefaModal extends StatefulWidget {
  final Tarefa? tarefa;

  TarefaModal({this.tarefa});

  @override
  _TarefaModalState createState() => _TarefaModalState();
}

class _TarefaModalState extends State<TarefaModal> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  bool _isLoading = false;
  /* int? _categoriaSelecionada; */

  @override
  void initState() {
    super.initState();
    if (widget.tarefa != null) {
      _tituloController.text = widget.tarefa!.titulo;
      _descricaoController.text = widget.tarefa!.descricao;
      _dataController.text = widget.tarefa!.data;
      _horaController.text = widget.tarefa!.hora;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarefaProvider = context.read<TarefaProvider>();
    final authProvider = context.read<AuthProvider>();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(labelText: 'Data'),
            ),
            TextField(
              controller: _horaController,
              decoration: const InputDecoration(labelText: 'Hora'),
            ),
            /* Consumer<Categoria>(
              builder: (context, categoryProvider, child) {
                return DropdownButton<int>(
                  hint: Text("Select Category"),
                  value: _selectedCategoryId,
                  items: categoryProvider.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                );
              },
            ), */
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_tituloController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Título não pode ser vazio')),
                        );
                        return;
                      }
                      if (_descricaoController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Descrição não pode ser vazio')),
                        );
                        return;
                      }
                      if (_dataController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Data não pode ser vazio')),
                        );
                        return;
                      }
                      if (_horaController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Hora não pode ser vazio')),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      Tarefa novaTarefa = Tarefa(
                        titulo: _tituloController.text,
                        descricao: _descricaoController.text,
                        data: _dataController.text,
                        hora: _horaController.text,
                        realizada: false,
                        categoriaId: 0,
                        usuarioId: authProvider.usuario!.id!,
                      );

                      if (widget.tarefa == null) {
                        await tarefaProvider.criaTarefa(novaTarefa);
                      } else {
                        novaTarefa.id = widget.tarefa!.id;
                        await tarefaProvider.editaTarefa(novaTarefa);
                      }

                      setState(() {
                        _isLoading = false;
                      });

                      Navigator.pop(context);
                    },
                    child: Text(widget.tarefa == null ? 'Criar' : 'Salvar'),
                  ),
          ],
        ),
      ),
    );
  }
}
