import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Identifiants de démonstration (tu peux les modifier)
  static const String identifiantCorrect = 'christian';
  static const String motDePasseCorrect = '1234';

  final TextEditingController _identifiantController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();

  bool _masquerMotDePasse = true;
  String _messageErreur = '';

  void _seConnecter() {
    final identifiant = _identifiantController.text.trim();
    final motDePasse = _motDePasseController.text;

    if (identifiant.isEmpty || motDePasse.isEmpty) {
      setState(() {
        _messageErreur = 'Veuillez remplir tous les champs.';
      });
    } else if (identifiant == identifiantCorrect &&
        motDePasse == motDePasseCorrect) {
      setState(() {
        _messageErreur = '';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        _messageErreur = 'Identifiant ou mot de passe incorrect.';
      });
    }
  }

  @override
  void dispose() {
    _identifiantController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 90, color: Colors.blue),
              const SizedBox(height: 12),
              const Text(
                'Connexion',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'CV de Christian Nkemba',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _identifiantController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _motDePasseController,
                obscureText: _masquerMotDePasse,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(_masquerMotDePasse
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _masquerMotDePasse = !_masquerMotDePasse;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_messageErreur.isNotEmpty)
                Text(
                  _messageErreur,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _seConnecter,
                  child: const Text('Se connecter',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}