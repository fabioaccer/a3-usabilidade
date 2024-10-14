import 'package:app_a3/db/lembrete_db.dart';
import 'package:flutter/material.dart';
import '../models/lembrete.dart';

class LembreteProvider with ChangeNotifier {
  List<Lembrete> _lembretes = [];
  List<Lembrete> get lembretes => _lembretes;

  Future<void> listaLembretes(int usuarioId) async {
    _lembretes = await LembreteDb().listarLembretes(usuarioId);
    notifyListeners();
  }

  Future<void> criaLembrete(Lembrete lembrete) async {
    await LembreteDb().criarLembrete(lembrete);
    notifyListeners();
  }

  Future<void> editaLembrete(Lembrete lembrete) async {
    await LembreteDb().editarLembrete(lembrete);
    notifyListeners();
  }

  Future<void> excluiLembrete(int id) async {
    await LembreteDb().excluirLembrete(id);
    notifyListeners();
  }
}
