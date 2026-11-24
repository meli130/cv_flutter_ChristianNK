import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class MembreFormPage extends StatefulWidget {
  // null = ajout, sinon = modification de ce membre
  final Membre? membre;
  const MembreFormPage({super.key, this.membre});

  @override
  State<MembreFormPage> createState() => _MembreFormPageState();
}

class _MembreFormPageState extends State<MembreFormPage> {
  final _nom = TextEditingController();
  final _postnom = TextEditingController();
  final _prenom = TextEditingController();
  final _lieu = TextEditingController();
  final _date = TextEditingController();
  final _parente = TextEditingController();

  Uint8List? _imageOctets;
  String? _imageNom;
  bool _chargement = false;
  String _erreur = '';

  bool get _modification => widget.membre != null;

  @override
  void initState() {
    super.initState();
    final m = widget.membre;
    if (m != null) {
      _nom.text = m.nom;
      _postnom.text = m.postnom;
      _prenom.text = m.prenom;
      _lieu.text = m.lieuNaissance;
      _date.text = m.dateNaissance;
      _parente.text = m.parente;
    }
  }

  @override
  void dispose() {
    _nom.dispose();
    _postnom.dispose();
    _prenom.dispose();
    _lieu.dispose();
    _date.dispose();
    _parente.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    DateTime initiale = DateTime(2000);
    final parsee = DateTime.tryParse(_date.text);
    if (parsee != null) initiale = parsee;

    final choix = await showDatePicker(
      context: context,
      initialDate: initiale,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (choix != null) {
      final mois = choix.month.toString().padLeft(2, '0');
      final jour = choix.day.toString().padLeft(2, '0');
      setState(() {
        _date.text = '${choix.year}-$mois-$jour'; // format AAAA-MM-JJ
      });
    }
  }

  Future<void> _choisirImage() async {
    final fichier = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (fichier != null) {
      final octets = await fichier.readAsBytes();
      setState(() {
        _imageOctets = octets;
        _imageNom = fichier.name;
      });
    }
  }

  Future<void> _enregistrer() async {
    final champs = [_nom, _postnom, _prenom, _lieu, _date, _parente];
    if (champs.any((c) => c.text.trim().isEmpty)) {
      setState(() => _erreur = 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() {
      _chargement = true;
      _erreur = '';
    });

    try {
      if (_modification) {
        await ApiService.modifierMembre(
          id: widget.membre!.id,
          nom: _nom.text.trim(),
          postnom: _postnom.text.trim(),
          prenom: _prenom.text.trim(),
          lieuNaissance: _lieu.text.trim(),
          dateNaissance: _date.text.trim(),
          parente: _parente.text.trim(),
          imageOctets: _imageOctets,
          imageNom: _imageNom,
        );
      } else {
        await ApiService.creerMembre(
          nom: _nom.text.trim(),
          postnom: _postnom.text.trim(),
          prenom: _prenom.text.trim(),
          lieuNaissance: _lieu.text.trim(),
          dateNaissance: _date.text.trim(),
          parente: _parente.text.trim(),
          imageOctets: _imageOctets,
          imageNom: _imageNom,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true); // true = il faut recharger la liste
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.message;
        _chargement = false;
      });
    }
  }

  Widget _champ(TextEditingController c, String label, IconData icone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icone),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _apercuImage() {
    Widget contenu;
    if (_imageOctets != null) {
      contenu = Image.memory(_imageOctets!, fit: BoxFit.cover);
    } else if (widget.membre?.imageUrl != null) {
      contenu = Image.network(widget.membre!.imageUrl!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, size: 50, color: Colors.white));
    } else {
      contenu = const Icon(Icons.person, size: 50, color: Colors.white);
    }
    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        color: Colors.grey,
        child: contenu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modification ? 'Modifier un membre' : 'Ajouter un membre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _apercuImage(),
            TextButton.icon(
              onPressed: _choisirImage,
              icon: const Icon(Icons.photo),
              label: Text(_imageOctets == null
                  ? 'Choisir une photo (facultatif)'
                  : 'Photo choisie : $_imageNom'),
            ),
            const SizedBox(height: 8),
            _champ(_nom, 'Nom', Icons.person),
            _champ(_postnom, 'Postnom', Icons.person_outline),
            _champ(_prenom, 'Prénom', Icons.badge),
            _champ(_lieu, 'Lieu de naissance', Icons.location_on),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _date,
                readOnly: true,
                onTap: _choisirDate,
                decoration: const InputDecoration(
                  labelText: 'Date de naissance (AAAA-MM-JJ)',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            _champ(_parente, 'Lien de parenté (ex. : Père, Mère, Frère)',
                Icons.family_restroom),
            if (_erreur.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_erreur,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
              ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _chargement ? null : _enregistrer,
                child: _chargement
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_modification ? 'Enregistrer' : 'Ajouter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}