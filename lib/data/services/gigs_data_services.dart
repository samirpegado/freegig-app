import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freegig_app/classes/datetime_convert.dart';
import 'package:freegig_app/data/services/data_common_task.dart';

class GigsDataService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> createNewGig({
    required String gigDescription,
    required String gigCity,
    required String gigAddress,
    required String gigInitHour,
    required String gigFinalHour,
    required String gigDate,
    required String gigCache,
    required List<String> gigCategorys,
    required String gigDetails,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentReference newGigRef = _firestore.collection('gigs').doc();

        await newGigRef.set({
          ///definicoes da gig
          'gigUid': newGigRef.id,
          'gigOwner': user.uid,
          'gigArchived': false,
          'gigCompleted': false,

          /// formularios da gig
          'gigDescription': gigDescription,
          'gigLocale': gigCity,
          'gigAdress': gigAddress,
          'gigInitHour': gigInitHour,
          'gigFinalHour': gigFinalHour,
          'gigDate': gigDate,
          'gigCache': gigCache,
          'gigCategorys': gigCategorys,
          'gigDetails': gigDetails,
          'gigParticipants': [user.uid],
        });
      }
    } catch (e) {
      print("Erro ao criar esta gig: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getCityActiveUserGigsStream({
    String? city,
    String? category,
    String? cache,
    String? data,
  }) {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        Query query = _firestore
            .collection('gigs')
            .where('gigArchived', isEqualTo: false)
            .where('gigOwner', isNotEqualTo: user.uid);

        if (city != null && city != 'Brasil') {
          query = query.where('gigLocale', isEqualTo: city);
        }

        if (category != null && category != 'Todos') {
          query = query.where('gigCategorys', arrayContains: category);
        }

        return query.snapshots().asyncExpand((gigsSnapshot) async* {
          /// Comparar
          List<Map<String, dynamic>> gigsDataList = [];

          for (QueryDocumentSnapshot gigDocument in gigsSnapshot.docs) {
            Map<String, dynamic> gigData =
                gigDocument.data() as Map<String, dynamic>;

            DocumentSnapshot userSnapshot = await _firestore
                .collection('users')
                .doc(gigData['gigOwner'])
                .get();

            Map<String, dynamic> userData =
                userSnapshot.data() as Map<String, dynamic>;

            bool dataCondition =
                data != null ? gigData['gigDate'] == data : true;

            if (dataCondition) {
              gigsDataList.add({
                ...gigData,
                'profileImageUrl': userData['profileImageUrl'],
                'publicName': userData['publicName'],
                'category': userData['category'],
              });
            }
          }

          if (cache == 'decreasing') {
            gigsDataList.sort((b, a) => a['gigCache'].compareTo(b['gigCache']));
          } else if (cache == 'increasing') {
            gigsDataList.sort((a, b) => a['gigCache'].compareTo(b['gigCache']));
          } else {
            gigsDataList.sort((a, b) {
              DateTime dateA = DateTimeConvert().parseDate(a['gigDate']);
              DateTime dateB = DateTimeConvert().parseDate(b['gigDate']);

              return dateA.compareTo(dateB);
            });
          }

          yield gigsDataList;
        });
      }
    } catch (e) {
      print("Erro ao buscar dados das GIGs: $e");
    }

    return Stream.value([]);
  }

  ///Funcao para listar as gigs que o usuário criou
  Stream<List<Map<String, dynamic>>> getMyActiveGigsStream() {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        return _firestore
            .collection('gigs')
            .where('gigArchived', isEqualTo: false)
            .where('gigOwner', isEqualTo: user.uid)
            .snapshots()
            .asyncMap((gigsSnapshot) async {
          return DataCommonTask().processGigData(gigsSnapshot);
        });
      }
    } catch (e) {
      print("Erro ao buscar dados das GIGs: $e");
    }
    // Retorna um stream vazio em caso de erro
    return Stream.value([]);
  }

  //Funcao para pegar as gigs que o usuario nao criou, mas que ele é participante
  Stream<List<Map<String, dynamic>>> getParticipantGigsStream() {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        return _firestore
            .collection('gigs')
            .where('gigArchived', isEqualTo: false)
            .where('gigParticipants', arrayContains: user.uid)
            .where('gigOwner', isNotEqualTo: user.uid)
            .snapshots()
            .asyncMap((gigsSnapshot) async {
          return DataCommonTask().processGigData(gigsSnapshot);
        });
      }
    } catch (e) {
      print("Erro ao buscar dados das GIGs: $e");
    }
    // Retorna um stream vazio em caso de erro
    return Stream.value([]);
  }

  // Funcao para pegar as gigs que o usuario criou e esta participando
  Stream<List<Map<String, dynamic>>> getMyAllGigsStream() {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        return _firestore
            .collection('gigs')
            .where('gigArchived', isEqualTo: false)
            .where('gigParticipants', arrayContains: user.uid)
            .snapshots()
            .asyncMap((gigsSnapshot) async {
          return DataCommonTask().processGigData(gigsSnapshot);
        });
      }
    } catch (e) {
      print("Erro ao buscar dados das GIGs: $e");
    }
    // Retorna um stream vazio em caso de erro
    return Stream.value([]);
  }

  // Funcao para deletar uma gig criada
  Future<void> myGigDelete(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('gigs')
          .doc(documentId)
          .delete();
      print('Documento removido com sucesso!');
    } catch (e) {
      print('Erro ao remover documento: $e');
    }
  }

  // Funcao para pegar os dados dos usuarios participantes de uma gig
  Future<List<Map<String, dynamic>>> getParticipantsData(String gigUid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> gigSnapshot =
          await _firestore.collection('gigs').doc(gigUid).get();

      if (!gigSnapshot.exists) {
        print('Gig com UID $gigUid não encontrado.');
        return [];
      }
      List<String> participantUids =
          List<String>.from(gigSnapshot['gigParticipants'] ?? []);

      List<Map<String, dynamic>> participantsData = [];

      for (String participantUid in participantUids) {
        DocumentSnapshot<Map<String, dynamic>> participantSnapshot =
            await _firestore.collection('users').doc(participantUid).get();

        if (participantSnapshot.exists) {
          Map<String, dynamic> participantData =
              participantSnapshot.data() ?? {};
          participantsData.add({
            'publicName': participantData['publicName'],
            'profileImageUrl': participantData['profileImageUrl'],
            'category': participantData['category'],
            'city': participantData['city'],
            'instagram': participantData['instagram'],
            'description': participantData['description'],
            'release': participantData['release'],
            'lastReleases': participantData['lastReleases'],
            'uid': participantUid,
          });
        } else {
          print('Usuário com UID $participantUid não encontrado.');
        }
      }

      return participantsData;
    } catch (e) {
      print('Erro ao obter dados dos participantes: $e');
      return [];
    }
  }

  Future<void> leaveGig({
    required String gigUid,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentReference<Map<String, dynamic>> requestedGigUpdate =
            _firestore.collection('gigs').doc(gigUid);

        DocumentSnapshot<Map<String, dynamic>> gigSnapshot =
            await requestedGigUpdate.get();

        List<String> gigParticipants =
            List<String>.from(gigSnapshot['gigParticipants'] ?? []);

        gigParticipants.remove(user.uid);

        await requestedGigUpdate.update({
          'gigParticipants': gigParticipants,
        });
      }
    } catch (e) {
      print("Erro ao aceitar a solicitação: $e");
    }
  }

  Future<void> updateGigStatus(bool newStatus, String gigUid) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('gigs')
            .doc(gigUid)
            .update({'gigCompleted': newStatus});
      }
    } catch (e) {
      print("Erro ao atualizar o status do usuário: $e");
    }
  }
}
