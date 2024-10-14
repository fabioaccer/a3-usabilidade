import 'package:app_a3/providers/categoria_provider.dart';
import 'package:app_a3/providers/lembrete_provider.dart';
import 'package:app_a3/screens/cadastro_screen.dart';
import 'package:app_a3/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/tarefa_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(NotysApp());
}

class NotysApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..verificaStatus()),
        ChangeNotifierProvider(create: (_) => TarefaProvider()),
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
        ChangeNotifierProvider(create: (_) => LembreteProvider()),
      ],
      child: MaterialApp(
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => AuthWrapper(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/cadastro': (context) => CadastroScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.usuario != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}
