import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../db/usuario_db.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  Future<bool> login(String email, String senha) async {
    Usuario? usuario = await UsuarioDb().listarUsuario(email, senha);
    if (usuario != null) {
      _usuario = usuario;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('usuarioId', usuario.id!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<String> cadastro(String email, String senha) async {
    Usuario? existe = await UsuarioDb().listarUsuarioPorEmail(email);

    if (existe != null) {
      return "Usuário já existe";
    } else {
      Usuario newUser = Usuario(email: email, senha: senha);
      int result = await UsuarioDb().criarUsuario(newUser);

      if (result > 0) {
        return "Cadastrado com sucesso";
      } else {
        return "Erro no cadastro";
      }
    }
  }

  Future<void> verificaStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? usuarioId = prefs.getInt('usuarioId');
    if (usuarioId != null) {
      _usuario = await UsuarioDb().listarUsuarioPorId(usuarioId);
      notifyListeners();
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('usuarioId');
    _usuario = null;
    notifyListeners();
  }
}
