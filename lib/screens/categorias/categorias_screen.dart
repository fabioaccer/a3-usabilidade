import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../models/categoria.dart';
import '../../providers/categoria_provider.dart';
import '../../providers/auth_provider.dart';
import 'categoria_modal.dart';
import 'tarefas_categoria_screen.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregaCategorias(context);
    });
  }

  Future<void> _carregaCategorias(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final categoriaProvider = Provider.of<CategoriaProvider>(context, listen: false);

    if (authProvider.usuario != null) {
      await categoriaProvider.listaCategorias(authProvider.usuario!.id!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Converte string de cor para Color
  Color _stringToColor(String? colorString) {
    if (colorString == null) return Colors.grey.shade100;
    return Color(int.parse(colorString.substring(1), radix: 16));
  }

  // Gera uma cor aleatória com brilho controlado
  Color _gerarCorAleatoria() {
    final random = Random();
    // Usando HSV para melhor controle sobre o brilho
    final hue = random.nextDouble() * 360; // Matiz aleatório
    final saturation = 0.3 + random.nextDouble() * 0.3; // Saturação entre 0.3 e 0.6
    final value = 0.8 + random.nextDouble() * 0.2; // Brilho entre 0.8 e 1.0
    
    return HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
  }

  Future<void> _abreModal(BuildContext context, {Categoria? categoria}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom,
      ),
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return CategoriaModal(categoria: categoria);
      },
    );
  }

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

    print('CategoriaScreen: Número de categorias: ${categoriaProvider.categorias.length}'); // Debug

    final filteredCategorias = categoriaProvider.categorias
        .where((categoria) =>
            categoria.nome.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

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
        title: Row(
          children: [
            Image.asset(
              'assets/icone.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            const Text('Minhas categorias'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar categorias...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredCategorias.isEmpty
                ? const Center(
                    child: Text('Nenhuma categoria encontrada'),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 16,
                          runSpacing: 16,
                          children: filteredCategorias.map((categoria) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: (MediaQuery.of(context).size.width - 48) / 2,
                                maxWidth: (MediaQuery.of(context).size.width - 48) / 2,
                              ),
                              child: Card(
                                elevation: 0,
                                color: _stringToColor(categoria.cor),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TarefasCategoriaScreen(
                                          categoria: categoria,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              categoria.nome,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              color: Colors.white,
                                              icon: const Icon(Icons.more_vert, color: Colors.white),
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
                                                if (value == 'edit') {
                                                  await _abreModal(context, categoria: categoria);
                                                } else if (value == 'delete') {
                                                  bool? confirmacao = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Excluir categoria'),
                                                      content: const Text('Tem certeza que deseja excluir esta categoria?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context, false),
                                                          child: const Text('Cancelar'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context, true),
                                                          child: const Text('Excluir'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirmacao == true) {
                                                    await categoriaProvider.excluiCategoria(categoria.id!);
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          _abreModal(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
