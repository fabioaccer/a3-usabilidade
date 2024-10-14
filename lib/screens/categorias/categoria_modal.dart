import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/categoria.dart';
import '../../providers/categoria_provider.dart';
import '../../providers/auth_provider.dart';

class CategoriaModal extends StatefulWidget {
  final Categoria? categoria;

  CategoriaModal({this.categoria});

  @override
  _CategoriaModalState createState() => _CategoriaModalState();
}

class _CategoriaModalState extends State<CategoriaModal> {
  final _nomeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nomeController.text = widget.categoria!.nome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriaProvider = context.read<CategoriaProvider>();
    final authProvider = context.read<AuthProvider>();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_nomeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Nome não pode ser vazio')),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      Categoria novaCategoria = Categoria(
                        nome: _nomeController.text,
                        usuarioId: authProvider.usuario!.id!,
                      );

                      if (widget.categoria == null) {
                        await categoriaProvider.criaCategoria(novaCategoria);
                      } else {
                        novaCategoria.id = widget.categoria!.id;
                        await categoriaProvider.editaCategoria(novaCategoria);
                      }

                      setState(() {
                        _isLoading = false;
                      });

                      Navigator.pop(context);
                    },
                    child: Text(widget.categoria == null ? 'Criar' : 'Salvar'),
                  ),
          ],
        ),
      ),
    );
  }
}
