import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            TextField(
              controller: _confirmaSenhaController,
              decoration: const InputDecoration(labelText: "Confirme a senha"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text;
                final senha = _senhaController.text;
                final confirmaSenha = _confirmaSenhaController.text;

                if (senha == confirmaSenha) {
                  String message = await authProvider.cadastro(email, senha);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );

                  if (message == "Cadastrado com sucesso") {
                    Navigator.pop(context);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("As senhas precisam ser iguais")),
                  );
                }
              },
              child: const Text("Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }
}
