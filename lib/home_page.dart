import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'cv_page.dart';
import 'family_page.dart';
import 'contact_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indexActuel = 0; // 0 = CV, 1 = Famille, 2 = Contact

  final List<Widget> _pages = const [
    CvPage(),
    FamilyPage(),
    ContactPage(),
  ];

  final List<String> _titres = const [
    'Mon CV',
    'Ma famille',
    'Contact',
  ];

  void _deconnexion() {
    ApiService.deconnecter();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titres[_indexActuel]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: _deconnexion,
          ),
        ],
      ),
      body: _pages[_indexActuel],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexActuel,
        onTap: (index) {
          setState(() {
            _indexActuel = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'CV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'Famille',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}