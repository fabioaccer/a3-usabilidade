import 'package:app_a3/screens/categorias/categorias_screen.dart';
import 'package:app_a3/screens/lembretes/lembretes_screen.dart';
import 'package:flutter/material.dart';
import './tarefas/tarefas_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indexSelecionado = 0;

  final List<Widget> _screens = [
    TarefasScreen(),
    CategoriasScreen(),
    LembretesScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _indexSelecionado = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_indexSelecionado],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Lembretes',
          ),
        ],
        currentIndex: _indexSelecionado,
        onTap: _onItemTapped,
      ),
    );
  }
}
