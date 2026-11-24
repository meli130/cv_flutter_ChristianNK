import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();

  bool _masquerMotDePasse = true;
  bool _chargement = false;
  String _messageErreur = '';
  String _messageSucces = '';

  bool _champsValides(String email, String motDePasse) {
    if (email.isEmpty || motDePasse.isEmpty) {
      setState(() {
        _messageErreur = 'Veuillez remplir tous les champs.';
        _messageSucces = '';
      });
      return false;
    }
    return true;
  }

  Future<void> _seConnecter() async {
    final email = _emailController.text.trim();
    final motDePasse = _motDePasseController.text;
    if (!_champsValides(email, motDePasse)) return;

    setState(() {
      _chargement = true;
      _messageErreur = '';
      _messageSucces = '';
    });

    try {
      await ApiService.connecter(email, motDePasse);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messageErreur = e.message;
        _chargement = false;
      });
    }
  }

  Future<void> _creerCompte() async {
    final email = _emailController.text.trim();
    final motDePasse = _motDePasseController.text;
    if (!_champsValides(email, motDePasse)) return;

    setState(() {
      _chargement = true;
      _messageErreur = '';
      _messageSucces = '';
    });

    try {
      await ApiService.inscrire(email, motDePasse);
      if (!mounted) return;
      setState(() {
        _messageSucces = 'Compte créé. Vous pouvez vous connecter.';
        _chargement = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messageErreur = e.message;
        _chargement = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
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
              if (_messageSucces.isNotEmpty)
                Text(
                  _messageSucces,
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _chargement ? null : _seConnecter,
                  child: _chargement
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Se connecter',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _chargement ? null : _creerCompte,
                child: const Text('Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}