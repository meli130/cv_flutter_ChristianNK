import 'dart:convert';
import 'package:http/http.dart' as http;

// Adresse de l'API (avec /public, obligatoire)
const String baseUrl = 'http://localhost/api-test/public';

// Un membre de la famille, tel que renvoyé par l'API
class Membre {
  final int id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance; // format AAAA-MM-JJ
  final String parente;
  final String? imageUrl;

  Membre({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  factory Membre.fromJson(Map<String, dynamic> json) {
    return Membre(
      id: int.parse(json['id'].toString()),
      nom: json['nom'] ?? '',
      postnom: json['postnom'] ?? '',
      prenom: json['prenom'] ?? '',
      lieuNaissance: json['lieu_naissance'] ?? '',
      dateNaissance: json['date_naissance'] ?? '',
      parente: json['parente'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  String get nomComplet => '$prenom $nom $postnom';
}

// Erreur renvoyée par l'API (message lisible)
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  // Compte actuellement connecté (null si personne)
  static String? emailConnecte;

  // Lit la réponse JSON et lève une erreur si success = false
  static Map<String, dynamic> _lireReponse(http.Response reponse) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(reponse.bodyBytes));
    } catch (_) {
      throw ApiException('Réponse invalide du serveur (code ${reponse.statusCode}).');
    }
    if (json['success'] != true) {
      String message = json['message']?.toString() ?? 'Erreur inconnue';
      final erreurs = json['errors'];
      if (erreurs is Map && erreurs.isNotEmpty) {
        message = erreurs.values.join('\n');
      }
      throw ApiException(message);
    }
    return json;
  }

  static Future<http.Response> _envoyer(Future<http.Response> Function() requete) async {
    try {
      return await requete().timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException(
          'Impossible de joindre le serveur. Vérifie que WAMP est démarré.');
    }
  }

  // ---------- COMPTES ----------

  static Future<void> inscrire(String email, String motDePasse) async {
    final reponse = await _envoyer(() => http.post(
          Uri.parse('$baseUrl/accounts/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': motDePasse}),
        ));
    _lireReponse(reponse);
  }

  static Future<void> connecter(String email, String motDePasse) async {
    final reponse = await _envoyer(() => http.post(
          Uri.parse('$baseUrl/accounts/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': motDePasse}),
        ));
    final json = _lireReponse(reponse);
    emailConnecte = json['data']['email'];
  }

  static void deconnecter() {
    emailConnecte = null;
  }

  // ---------- MEMBRES DE FAMILLE ----------

  static Future<List<Membre>> listerMembres() async {
    final reponse =
        await _envoyer(() => http.get(Uri.parse('$baseUrl/famille-membres')));
    final json = _lireReponse(reponse);
    final liste = json['data'] as List;
    return liste.map((e) => Membre.fromJson(e)).toList();
  }

  static Map<String, String> _champs({
    required String nom,
    required String postnom,
    required String prenom,
    required String lieuNaissance,
    required String dateNaissance,
    required String parente,
  }) {
    return {
      'nom': nom,
      'postnom': postnom,
      'prenom': prenom,
      'lieu_naissance': lieuNaissance,
      'date_naissance': dateNaissance,
      'parente': parente,
    };
  }

  // Créer un membre (image facultative)
  static Future<void> creerMembre({
    required String nom,
    required String postnom,
    required String prenom,
    required String lieuNaissance,
    required String dateNaissance,
    required String parente,
    List<int>? imageOctets,
    String? imageNom,
  }) async {
    final champs = _champs(
      nom: nom,
      postnom: postnom,
      prenom: prenom,
      lieuNaissance: lieuNaissance,
      dateNaissance: dateNaissance,
      parente: parente,
    );

    if (imageOctets == null) {
      // Sans image : JSON
      final reponse = await _envoyer(() => http.post(
            Uri.parse('$baseUrl/famille-membres'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(champs),
          ));
      _lireReponse(reponse);
    } else {
      // Avec image : multipart/form-data
      final reponse = await _envoyer(() async {
        final requete =
            http.MultipartRequest('POST', Uri.parse('$baseUrl/famille-membres'));
        requete.fields.addAll(champs);
        requete.files.add(http.MultipartFile.fromBytes('image', imageOctets,
            filename: imageNom ?? 'photo.jpg'));
        return http.Response.fromStream(await requete.send());
      });
      _lireReponse(reponse);
    }
  }

  // Modifier un membre (tous les champs obligatoires sont renvoyés)
  static Future<void> modifierMembre({
    required int id,
    required String nom,
    required String postnom,
    required String prenom,
    required String lieuNaissance,
    required String dateNaissance,
    required String parente,
    List<int>? imageOctets,
    String? imageNom,
  }) async {
    final champs = _champs(
      nom: nom,
      postnom: postnom,
      prenom: prenom,
      lieuNaissance: lieuNaissance,
      dateNaissance: dateNaissance,
      parente: parente,
    );

    if (imageOctets == null) {
      // Sans changer l'image : PUT en JSON
      final reponse = await _envoyer(() => http.put(
            Uri.parse('$baseUrl/famille-membres/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(champs),
          ));
      _lireReponse(reponse);
    } else {
      // En changeant l'image : POST multipart sur /{id}
      final reponse = await _envoyer(() async {
        final requete = http.MultipartRequest(
            'POST', Uri.parse('$baseUrl/famille-membres/$id'));
        requete.fields.addAll(champs);
        requete.files.add(http.MultipartFile.fromBytes('image', imageOctets,
            filename: imageNom ?? 'photo.jpg'));
        return http.Response.fromStream(await requete.send());
      });
      _lireReponse(reponse);
    }
  }

  static Future<void> supprimerMembre(int id) async {
    final reponse = await _envoyer(
        () => http.delete(Uri.parse('$baseUrl/famille-membres/$id')));
    _lireReponse(reponse);
  }
}