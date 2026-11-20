import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  // ====== DONNÉES À MODIFIER FACILEMENT ======
  static const String telephone = '+2439706505353';
  static const String email = 'nkembachristian@gmail.com';
  static const String ville = 'Goma, RD Congo';
  static const String github = 'github.com/meli130/my-profil/deployments/github-pages';
  static const String linkedin = 'www.linkedin.com/in/christian-nkemba-010652200/';
  // ===========================================

  // Ouvre un lien (appel, e-mail ou site web)
  Future<void> _ouvrir(BuildContext context, String adresse) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(
      Uri.parse(adresse),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir ce lien.')),
      );
    }
  }

  // Une ligne de contact. 'adresse' = ce qui s'ouvre au clic (null = pas cliquable)
  Widget _ligne(BuildContext context, IconData icone, String titre,
      String valeur, String? adresse) {
    // Pas cliquable tant que l'info n'est pas complétée
    final cliquable = adresse != null && !valeur.contains('[');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icone, color: Colors.blue.shade700, size: 30),
        title: Text(titre,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(valeur),
        trailing: cliquable
            ? Icon(Icons.open_in_new, color: Colors.blue.shade700)
            : null,
        onTap: cliquable ? () => _ouvrir(context, adresse) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ligne(context, Icons.phone, 'Téléphone', telephone,
            'tel:${telephone.replaceAll(' ', '')}'),
        _ligne(context, Icons.email, 'E-mail', email, 'mailto:$email'),
        _ligne(context, Icons.location_on, 'Ville', ville, null),
        _ligne(context, Icons.code, 'GitHub', github, 'https://$github'),
        _ligne(context, Icons.work, 'LinkedIn', linkedin, 'https://$linkedin'),
      ],
    );
  }
}