import 'package:flutter/material.dart';

class CvPage extends StatelessWidget {
  const CvPage({super.key});

  // ====== DONNÉES À MODIFIER FACILEMENT ======
  static const String nom = 'Christian Nkemba';
  static const String titre = 'Étudiant en informatique (L3 LSI)';
  static const String localisation = 'Goma, RD Congo';

  static const List<String> formations = [
    'L3 LSI (Licence 3) : ISIG Goma, en cours',
    'Diplôme d\'État : Technique Commerciale et Gestion',
    'Formation Hikvision : vidéosurveillance et contrôle d\'accès',
    'Formation Cisco : cybersécurité',
  ];

  static const List<String> projets = [
    'Installation et configuration de caméras de surveillance',
    'Extension et configuration de réseaux informatiques',
    '[À compléter] Projet personnel ou académique',
  ];

  static const List<String> competencesFormations = [
    'Vidéosurveillance Hikvision',
    'Contrôle d\'accès',
    'Cybersécurité (Cisco)',
    'Notions de réseaux informatiques',
  ];

  static const List<String> competencesApprentissage = [
    'Flutter et Dart',
    'C#',
    'HTML et CSS',
    'SQL et bases de données',
    'Linux',
  ];

  static const List<String> langues = [
    'Français : [tres bon niveau]',
    'Anglais : [bon niveau]',
    'Swahili : [bon niveau]',
  ];

  static const List<String> interets = [
    'Informatique et nouvelles technologies',
    'Réseaux et télécommunications',
    'Développement de projets',
    'Sport',
    'Lecture et développement personnel',
  ];
  // ===========================================

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _entete(),
          const SizedBox(height: 16),
          _section('Formation', Icons.school, formations),
          _section('Expériences et projets', Icons.build, projets),
          _section('Compétences : formations suivies', Icons.verified,
              competencesFormations),
          _section('Compétences : domaines d\'apprentissage', Icons.code,
              competencesApprentissage),
          _section('Langues', Icons.language, langues),
          _section('Centres d\'intérêt', Icons.favorite, interets),
        ],
      ),
    );
  }

  Widget _entete() {
    return Card(
      color: Colors.blue.shade700,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/moi.jpg'),
            ),
            const SizedBox(height: 12),
            const Text(
              nom,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              titre,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              localisation,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String titreSection, IconData icone, List<String> lignes) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: const Color.fromARGB(255, 0, 77, 50)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titreSection,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            for (final ligne in lignes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(ligne)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}