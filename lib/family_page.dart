import 'package:flutter/material.dart';

// Un membre de la famille = 3 informations + une photo (optionnelle)
class MembreFamille {
  final String nom;
  final String lien;
  final String profession;
  final String? photo; // chemin de l'image, ou null si pas encore de photo

  const MembreFamille({
    required this.nom,
    required this.lien,
    required this.profession,
    this.photo,
  });
}

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  // ====== DONNÉES À MODIFIER FACILEMENT ======
  // Une ligne MembreFamille(...) par personne.
  // Pour ajouter une photo plus tard : photo: 'assets/images/papa.jpg'
  static const List<MembreFamille> membres = [
    MembreFamille(
  nom: 'papa',
  lien: 'Père',
  profession: 'medecin',
  photo: 'assets/images/papa.jpg',
),
    MembreFamille(
      nom: 'ma petite soeur',
      lien: 'Mère',
      profession: 'eleve',
      photo: 'assets/images/petite_soeur.jpg'
    ),
    MembreFamille(
  nom: 'maman',
  lien: 'mere',
  profession: 'menagere',
  photo: 'assets/images/maman.jpg',
),
  MembreFamille(
  nom: 'frero',
  lien: 'frere',
  profession: 'chomeur',
  photo: 'assets/images/frere.jpg',
),
    
  ];
  // ===========================================

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: membres.length,
      itemBuilder: (context, index) {
        final membre = membres[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _photo(membre.photo),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        membre.nom,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        membre.lien,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Profession : ${membre.profession}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Affiche la photo si elle existe, sinon une icône grise
  Widget _photo(String? chemin) {
    if (chemin == null) {
      return const CircleAvatar(
        radius: 36,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 40, color: Colors.white),
      );
    }
    return CircleAvatar(
      radius: 36,
      backgroundImage: AssetImage(chemin),
    );
  }
}