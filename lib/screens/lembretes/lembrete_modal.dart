import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lembrete.dart';
import '../../providers/lembrete_provider.dart';
import '../../providers/auth_provider.dart';

class LembreteModal extends StatefulWidget {
  final Lembrete? lembrete;

  LembreteModal({this.lembrete});

  @override
  _LembreteModalState createState() => _LembreteModalState();
}

class _LembreteModalState extends State<LembreteModal> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.lembrete != null) {
      _tituloController.text = widget.lembrete!.titulo;
      _descricaoController.text = widget.lembrete!.descricao;
      _dataController.text = widget.lembrete!.data;
      _horaController.text = widget.lembrete!.hora;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lembreteProvider = context.read<LembreteProvider>();
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

                      Lembrete novoLembrete = Lembrete(
                        titulo: _tituloController.text,
                        descricao: _descricaoController.text,
                        data: _dataController.text,
                        hora: _horaController.text,
                        usuarioId: authProvider.usuario!.id!,
                      );

                      if (widget.lembrete == null) {
                        await lembreteProvider.criaLembrete(novoLembrete);
                      } else {
                        novoLembrete.id = widget.lembrete!.id;
                        await lembreteProvider.editaLembrete(novoLembrete);
                      }

                      setState(() {
                        _isLoading = false;
                      });

                      Navigator.pop(context);
                    },
                    child: Text(widget.lembrete == null ? 'Criar' : 'Salvar'),
                  ),
          ],
        ),
      ),
    );
  }
}
