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

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho fixo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  widget.categoria == null ? 'Nova Categoria' : 'Editar Categoria',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo scrollável
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        hintText: 'Nome da categoria',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Botão fixo no bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.categoria == null ? 'Criar Categoria' : 'Salvar Alterações',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
