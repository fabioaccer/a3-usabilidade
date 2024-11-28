import 'package:listvo/providers/lembrete_provider.dart';
import 'package:listvo/screens/lembretes/lembrete_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lembrete.dart';
import '../../providers/auth_provider.dart';
import 'lembrete_detalhes_modal.dart';

class LembretesScreen extends StatefulWidget {
  const LembretesScreen({super.key});

  @override
  State<LembretesScreen> createState() => _LembretesScreenState();
}

class _LembretesScreenState extends State<LembretesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregaLembretes(context);
    });
  }

  Future<void> _carregaLembretes(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lembreteProvider = Provider.of<LembreteProvider>(context, listen: false);
    
    if (authProvider.usuario != null) {
      await lembreteProvider.carregaLembretes(authProvider.usuario!.id!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _abreModal(BuildContext context, {Lembrete? lembrete}) async {
    if (context.mounted) {
      showModalBottomSheet(
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
          return LembreteModal(lembrete: lembrete);
        },
      );
    }
  }

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

    final lembretesFiltrados = _searchController.text.isEmpty
        ? lembreteProvider.lembretes
        : lembreteProvider.lembretes.where((lembrete) =>
            lembrete.titulo.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            lembrete.descricao.toLowerCase().contains(_searchController.text.toLowerCase())
          ).toList();

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
            const Text('Meus lembretes'),
          ],
        ),
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
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar lembretes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: lembretesFiltrados.isEmpty
                ? const Center(
                    child: Text('Nenhum lembrete encontrado'),
                  )
                : ListView.builder(
                    itemCount: lembretesFiltrados.length,
                    itemBuilder: (context, index) {
                      final lembrete = lembretesFiltrados[index];
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
                                  if (value == 'edit') {
                                    await _abreModal(context, lembrete: lembrete);
                                  } else if (value == 'delete') {
                                    bool? confirmacao = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Excluir lembrete'),
                                        content: const Text('Tem certeza que deseja excluir este lembrete?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await lembreteProvider.deletaLembrete(lembrete.id!);
                                            },
                                            child: const Text(
                                              'Excluir',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _abreModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
