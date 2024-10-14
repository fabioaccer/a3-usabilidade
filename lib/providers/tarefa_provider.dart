import 'package:app_a3/db/tarefa_db.dart';
import 'package:flutter/material.dart';
import '../models/tarefa.dart';

class TarefaProvider with ChangeNotifier {
  List<Tarefa> _tarefas = [];
  List<Tarefa> get tarefas => _tarefas;

  Future<void> listaTarefas(int usuarioId) async {
    _tarefas = await TarefaDb().listarTarefas(usuarioId);
    notifyListeners();
  }

  Future<void> criaTarefa(Tarefa tarefa) async {
    await TarefaDb().criarTarefa(tarefa);
    notifyListeners();
  }

  Future<void> editaTarefa(Tarefa tarefa) async {
    await TarefaDb().editarTarefa(tarefa);
    notifyListeners();
  }

  Future<void> excluiTarefa(int id) async {
    await TarefaDb().excluirTarefa(id);
    notifyListeners();
  }
}
