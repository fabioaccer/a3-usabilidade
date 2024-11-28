import 'package:listvo/db/tarefa_db.dart';
import 'package:flutter/material.dart';
import '../models/tarefa.dart';

class TarefaProvider with ChangeNotifier {
  List<Tarefa> _tarefas = [];
  List<Tarefa> get tarefas => _tarefas;

  Future<void> listaTarefas(int usuarioId) async {
    _tarefas = await TarefaDb().listarTarefas(usuarioId);
    notifyListeners();
  }

  Future<void> listaTarefasPorCategoria(int usuarioId, int categoriaId) async {
    _tarefas = await TarefaDb().listarTarefas(usuarioId);
    _tarefas = _tarefas.where((tarefa) => tarefa.categoriaId == categoriaId).toList();
    notifyListeners();
  }

  Future<int> criaTarefa(Tarefa tarefa) async {
    final id = await TarefaDb().criarTarefa(tarefa);
    await listaTarefas(tarefa.usuarioId);
    return id;
  }

  Future<void> editaTarefa(Tarefa tarefa) async {
    await TarefaDb().editarTarefa(tarefa);
    await listaTarefas(tarefa.usuarioId);
  }

  Future<void> excluiTarefa(int id, int usuarioId) async {
    await TarefaDb().excluirTarefa(id);
    await listaTarefas(usuarioId);
  }
}
