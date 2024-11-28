import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tarefa.dart';
import '../../models/categoria.dart';
import '../../providers/tarefa_provider.dart';
import '../../providers/auth_provider.dart';
import '../lembretes/lembretes_tarefa_screen.dart';
import '../tarefas/tarefa_modal.dart';
import '../tarefas/tarefa_detalhes_modal.dart';

class TarefasCategoriaScreen extends StatefulWidget {
  final Categoria categoria;

  const TarefasCategoriaScreen({super.key, required this.categoria});

  @override
  State<TarefasCategoriaScreen> createState() => _TarefasCategoriaScreenState();
}

class _TarefasCategoriaScreenState extends State<TarefasCategoriaScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregaTarefas(context);
    });
  }

  Future<void> _carregaTarefas(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tarefaProvider = Provider.of<TarefaProvider>(context, listen: false);
    
    if (authProvider.usuario != null) {
      await tarefaProvider.listaTarefasPorCategoria(
        authProvider.usuario!.id!,
        widget.categoria.id!
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _abreModal(BuildContext context, {Tarefa? tarefa}) async {
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
          return TarefaModal(tarefa: tarefa, categoriaId: widget.categoria.id);
        },
      );
    }
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

    final tarefas = tarefaProvider.tarefas
        .where((tarefa) => tarefa.categoriaId == widget.categoria.id)
        .toList();

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
        title: Text(widget.categoria.nome),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Pendentes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    leading: Checkbox(
                                      value: tarefa.realizada,
                                      onChanged: (bool? value) async {
                                        tarefa.realizada = value ?? false;
                                        await tarefaProvider.editaTarefa(tarefa);
                                        await _carregaTarefas(context);
                                      },
                                    ),
                                    title: Text(
                                      tarefa.titulo,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [/* 
                                        Text(
                                          tarefa.descricao,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4), */
                                        Text('${tarefa.data} às ${tarefa.hora}'),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'details',
                                          child: Row(
                                            children: [
                                              Icon(Icons.info),
                                              SizedBox(width: 8),
                                              Text('Ver detalhes'),
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
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Editar'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete),
                                              SizedBox(width: 8),
                                              Text('Excluir'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 'details':
                                            showDialog(
                                              context: context,
                                              builder: (context) => TarefaDetalhesModal(tarefa: tarefa),
                                            );
                                            break;
                                          case 'lembretes':
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LembretesTarefaScreen(
                                                  tarefa: tarefa,
                                                ),
                                              ),
                                            );
                                            break;
                                          case 'edit':
                                            await _abreModal(context, tarefa: tarefa);
                                            break;
                                          case 'delete':
                                            bool? confirmacao = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Excluir tarefa'),
                                                content: const Text('Tem certeza que deseja excluir esta tarefa?'),
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
                                              await tarefaProvider.excluiTarefa(tarefa.id!, tarefa.usuarioId);
                                            }
                                            break;
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Realizadas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    leading: Checkbox(
                                      value: tarefa.realizada,
                                      onChanged: (bool? value) async {
                                        tarefa.realizada = value ?? false;
                                        await tarefaProvider.editaTarefa(tarefa);
                                        await _carregaTarefas(context);
                                      },
                                    ),
                                    title: Text(
                                      tarefa.titulo,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tarefa.descricao,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${tarefa.data} às ${tarefa.hora}'),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'details',
                                          child: Row(
                                            children: [
                                              Icon(Icons.info),
                                              SizedBox(width: 8),
                                              Text('Ver detalhes'),
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
                                              Icon(Icons.delete),
                                              SizedBox(width: 8),
                                              Text('Excluir'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 'details':
                                            showDialog(
                                              context: context,
                                              builder: (context) => TarefaDetalhesModal(tarefa: tarefa),
                                            );
                                            break;
                                          case 'lembretes':
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LembretesTarefaScreen(
                                                  tarefa: tarefa,
                                                ),
                                              ),
                                            );
                                            break;
                                          case 'delete':
                                            bool? confirmacao = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Excluir tarefa'),
                                                content: const Text('Tem certeza que deseja excluir esta tarefa?'),
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
                                              await tarefaProvider.excluiTarefa(tarefa.id!, tarefa.usuarioId);
                                            }
                                            break;
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
        onPressed: () => _abreModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
