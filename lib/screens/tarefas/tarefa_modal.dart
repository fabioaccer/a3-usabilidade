import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../models/tarefa.dart';
import '../../providers/tarefa_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/categoria.dart';
import '../../providers/categoria_provider.dart';
import 'package:listvo/providers/lembrete_provider.dart';
import 'package:listvo/models/lembrete.dart';

class TarefaModal extends StatefulWidget {
  final Tarefa? tarefa;
  final int? categoriaId;

  TarefaModal({this.tarefa, this.categoriaId});

  @override
  _TarefaModalState createState() => _TarefaModalState();
}

class _TarefaModalState extends State<TarefaModal> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  bool _isLoading = false;
  int? _categoriaSelecionada;

  final _dataMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _horaMaskFormatter = MaskTextInputFormatter(
    mask: '##:##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();

    // Se foi passado um categoriaId, usa ele como categoria selecionada
    if (widget.categoriaId != null) {
      _categoriaSelecionada = widget.categoriaId;
    }

    if (widget.tarefa != null) {
      _tituloController.text = widget.tarefa!.titulo;
      _descricaoController.text = widget.tarefa!.descricao;
      _dataController.text = widget.tarefa!.data;
      _horaController.text = widget.tarefa!.hora;
      _categoriaSelecionada = widget.tarefa!.categoriaId;
    }
  }

  Future<void> _selecionaData(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        _dataController.text = '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
      });
    }
  }

  Future<void> _selecionaHora(BuildContext context) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        _horaController.text = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _salvaTarefa() async {
    setState(() {
      _isLoading = true;
    });

    Tarefa novaTarefa = Tarefa(
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      data: _dataController.text,
      hora: _horaController.text,
      categoriaId: _categoriaSelecionada,
      usuarioId: Provider.of<AuthProvider>(context, listen: false).usuario!.id!,
      realizada: false,
    );

    try {
      if (widget.tarefa != null) {
        novaTarefa.id = widget.tarefa!.id;
        await Provider.of<TarefaProvider>(context, listen: false).editaTarefa(novaTarefa);
      } else {
        final tarefaId = await Provider.of<TarefaProvider>(context, listen: false).criaTarefa(novaTarefa);
        
        // Criar lembrete junto com a tarefa
        if (_dataController.text.isNotEmpty && _horaController.text.isNotEmpty) {
          final lembreteProvider = Provider.of<LembreteProvider>(context, listen: false);
          final lembrete = Lembrete(
            titulo: _tituloController.text,
            descricao: _descricaoController.text,
            data: _dataController.text,
            hora: _horaController.text,
            usuarioId: Provider.of<AuthProvider>(context, listen: false).usuario!.id!,
            tarefaId: tarefaId,
          );
          await lembreteProvider.criaLembrete(lembrete);
        }
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar a tarefa'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarefaProvider = context.read<TarefaProvider>();
    final authProvider = context.read<AuthProvider>();
    final categoriaProvider = context.read<CategoriaProvider>();

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
                  widget.tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa',
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
                      controller: _tituloController,
                      decoration: InputDecoration(
                        hintText: 'Título da tarefa',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descricaoController,
                      decoration: InputDecoration(
                        hintText: 'Descrição',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dataController,
                            readOnly: true,
                            onTap: () => _selecionaData(context),
                            decoration: InputDecoration(
                              hintText: 'Data',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: const Icon(Icons.calendar_today, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _horaController,
                            readOnly: true,
                            onTap: () => _selecionaHora(context),
                            decoration: InputDecoration(
                              hintText: 'Hora',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: const Icon(Icons.access_time, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<CategoriaProvider>(
                      builder: (context, categoriaProvider, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              isExpanded: true,
                              hint: const Text('Selecione uma categoria (opcional)'),
                              value: _categoriaSelecionada,
                              items: categoriaProvider.categorias.map((categoria) {
                                return DropdownMenuItem<int>(
                                  value: categoria.id,
                                  child: Text(categoria.nome),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _categoriaSelecionada = value;
                                });
                              },
                            ),
                          ),
                        );
                      },
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
                    onPressed: _salvaTarefa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.tarefa == null ? 'Criar Tarefa' : 'Salvar Alterações',
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
