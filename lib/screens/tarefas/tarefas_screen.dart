import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tarefa.dart';
import '../../providers/tarefa_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/categoria_provider.dart';
import '../lembretes/lembretes_tarefa_screen.dart';
import 'tarefa_modal.dart';
import 'tarefa_detalhes_modal.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final _searchController = TextEditingController();

  Future<void> _carregaCategorias(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final categoriaProvider = Provider.of<CategoriaProvider>(context, listen: false);
    
    if (authProvider.usuario != null) {
      await categoriaProvider.listaCategorias(authProvider.usuario!.id!);
    }
  }

  Future<void> _abreModal(BuildContext context, {Tarefa? tarefa}) async {
    await _carregaCategorias(context);
    
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
          return TarefaModal(tarefa: tarefa);
        },
      );
    }
  }

  Future<void> _carregaTarefas(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tarefaProvider = Provider.of<TarefaProvider>(context, listen: false);
    
    if (authProvider.usuario != null) {
      await tarefaProvider.listaTarefas(authProvider.usuario!.id!);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregaTarefas(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

    final tarefas = tarefaProvider.tarefas;
    
    // Primeiro filtra as tarefas baseado na pesquisa
    final tarefasFiltradas = _searchController.text.isEmpty 
        ? tarefas 
        : tarefas.where((tarefa) => 
            tarefa.titulo.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            tarefa.descricao.toLowerCase().contains(_searchController.text.toLowerCase())
          ).toList();
    
    // Depois separa em pendentes e realizadas
    final tarefasPendentes = tarefasFiltradas.where((tarefa) => !tarefa.realizada).toList();
    final tarefasRealizadas = tarefasFiltradas.where((tarefa) => tarefa.realizada).toList();

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
            const Text('Minhas tarefas'),
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
                hintText: 'Pesquisar tarefas...',
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                            child: Text(
                              'Pendentes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (tarefasPendentes.isEmpty)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    _searchController.text.isEmpty
                                        ? 'Nenhuma tarefa pendente'
                                        : 'Nenhuma tarefa pendente encontrada',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tarefasPendentes.length,
                              itemBuilder: (context, index) {
                                final tarefa = tarefasPendentes[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: IconButton(
                                      icon: const Icon(Icons.check_box_outline_blank, size: 20),
                                      onPressed: () async {
                                        tarefa.realizada = true;
                                        await tarefaProvider.editaTarefa(tarefa);
                                      },
                                      padding: EdgeInsets.zero,
                                    ),
                                    title: Text(tarefa.titulo),
                                    subtitle: Text(
                                      '${tarefa.data} às ${tarefa.hora}',
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      color: Colors.white,
                                      icon: const Icon(Icons.more_vert, size: 20),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'details',
                                          child: Row(
                                            children: [
                                              Icon(Icons.info_outline),
                                              SizedBox(width: 8),
                                              Text('Ver detalhes'),
                                            ],
                                          ),
                                        ),
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
                                          value: 'lembretes',
                                          child: Row(
                                            children: [
                                              Icon(Icons.notifications),
                                              SizedBox(width: 8),
                                              Text('Ver Lembretes'),
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
                                        if (value == 'details') {
                                          showDialog(
                                            context: context,
                                            builder: (context) => TarefaDetalhesModal(tarefa: tarefa),
                                          );
                                        } else if (value == 'edit') {
                                          await _abreModal(context, tarefa: tarefa);
                                        } else if (value == 'lembretes') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LembretesTarefaScreen(
                                                tarefa: tarefa,
                                              ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          final confirma = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: const Text('Excluir tarefa'),
                                              content: const Text('Tem certeza que deseja excluir esta tarefa?'),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancelar'),
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                ),
                                                TextButton(
                                                  child: const Text('Excluir'),
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirma == true) {
                                            await tarefaProvider.excluiTarefa(tarefa.id!, tarefa.usuarioId);
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                            child: Text(
                              'Realizadas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (tarefasRealizadas.isEmpty)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    _searchController.text.isEmpty
                                        ? 'Nenhuma tarefa realizada'
                                        : 'Nenhuma tarefa realizada encontrada',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tarefasRealizadas.length,
                              itemBuilder: (context, index) {
                                final tarefa = tarefasRealizadas[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: IconButton(
                                      icon: const Icon(Icons.check_box, size: 20),
                                      onPressed: () async {
                                        tarefa.realizada = false;
                                        await tarefaProvider.editaTarefa(tarefa);
                                      },
                                      padding: EdgeInsets.zero,
                                    ),
                                    title: Text(
                                      tarefa.titulo,
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${tarefa.data} às ${tarefa.hora}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      color: Colors.white,
                                      icon: const Icon(Icons.more_vert, size: 20),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'details',
                                          child: Row(
                                            children: [
                                              Icon(Icons.info_outline),
                                              SizedBox(width: 8),
                                              Text('Ver detalhes'),
                                            ],
                                          ),
                                        ),
                                        /* const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text('Editar'),
                                            ],
                                          ),
                                        ), */
                                        const PopupMenuItem(
                                          value: 'lembretes',
                                          child: Row(
                                            children: [
                                              Icon(Icons.notifications),
                                              SizedBox(width: 8),
                                              Text('Ver Lembretes'),
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
                                        if (value == 'details') {
                                          showDialog(
                                            context: context,
                                            builder: (context) => TarefaDetalhesModal(tarefa: tarefa),
                                          );
                                        } else if (value == 'edit') {
                                          await _abreModal(context, tarefa: tarefa);
                                        } else if (value == 'lembretes') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LembretesTarefaScreen(
                                                tarefa: tarefa,
                                              ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          final confirma = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: const Text('Excluir tarefa'),
                                              content: const Text('Tem certeza que deseja excluir esta tarefa?'),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancelar'),
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                ),
                                                TextButton(
                                                  child: const Text('Excluir'),
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirma == true) {
                                            await tarefaProvider.excluiTarefa(tarefa.id!, tarefa.usuarioId);
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () async {
          await _abreModal(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
