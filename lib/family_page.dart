import 'package:flutter/material.dart';
import 'api_service.dart';
import 'membre_form_page.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  late Future<List<Membre>> _membres;

  @override
  void initState() {
    super.initState();
    _membres = ApiService.listerMembres();
  }

  void _recharger() {
    setState(() {
      _membres = ApiService.listerMembres();
    });
  }

  Future<void> _ouvrirFormulaire([Membre? membre]) async {
    final modifie = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MembreFormPage(membre: membre)),
    );
    if (modifie == true) _recharger();
  }

  Future<void> _supprimer(Membre membre) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text(membre.nomComplet),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirme != true) return;

    try {
      await ApiService.supprimerMembre(membre.id);
      messenger.showSnackBar(const SnackBar(content: Text('Membre supprimé.')));
      _recharger();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Widget _photo(Membre membre) {
    const vide = Icon(Icons.person, size: 40, color: Colors.white);
    return ClipOval(
      child: Container(
        width: 72,
        height: 72,
        color: Colors.grey,
        child: membre.imageUrl == null
            ? vide
            : Image.network(
                membre.imageUrl!,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                errorBuilder: (_, __, ___) => vide,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ouvrirFormulaire(),
        tooltip: 'Ajouter un membre',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Membre>>(
        future: _membres,
        builder: (context, instantane) {
          if (instantane.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (instantane.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(instantane.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: _recharger, child: const Text('Réessayer')),
                  ],
                ),
              ),
            );
          }

          final membres = instantane.data!;
          if (membres.isEmpty) {
            return const Center(
              child: Text('Aucun membre. Appuie sur + pour en ajouter.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _recharger(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: membres.length,
              itemBuilder: (context, index) {
                final m = membres[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        _photo(m),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.nomComplet,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(m.parente,
                                  style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600)),
                              Text('Né(e) le ${m.dateNaissance} à ${m.lieuNaissance}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue.shade700),
                          tooltip: 'Modifier',
                          onPressed: () => _ouvrirFormulaire(m),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Supprimer',
                          onPressed: () => _supprimer(m),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}