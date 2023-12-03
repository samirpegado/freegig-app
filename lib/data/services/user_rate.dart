import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class UserRateService {
  Future<Map<String, dynamic>> getGigData(String gigUid) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot gigSnapshot =
            await _firestore.collection('gigs').doc(gigUid).get();

        if (gigSnapshot.exists) {
          return {
            'currentUser': user.uid,
            'gigDate': gigSnapshot['gigDate'],
            'gigLocale': gigSnapshot['gigLocale'],
            'gigDescription': gigSnapshot['gigDescription'],
          };
        }
      }
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> getRateParticipantsData(
      String gigUid) async {
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

  Future<void> rateNotificationDelete(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rateNotification')
          .doc(documentId)
          .delete();
      print('Documento removido com sucesso!');
    } catch (e) {
      print('Erro ao remover documento: $e');
    }
  }

  Future<void> rateNotification({
    required String participantUid,
    required String gigUid,
  }) async {
    try {
      DocumentReference newRateNotice =
          _firestore.collection('rateNotification').doc();

      await newRateNotice.set({
        'rateNotificationUid': newRateNotice.id,
        'participantUid': participantUid,
        'gigUid': gigUid,
      });
    } catch (e) {
      print("Erro ao criar esta gig: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getRateNotifications() async {
    try {
      User? user = _auth.currentUser;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('rateNotification')
              .where('participantUid', isEqualTo: user!.uid)
              .get();

      List<Map<String, dynamic>> rateNotifications = [];

      // Itera sobre os documentos do QuerySnapshot e adiciona à lista
      querySnapshot.docs.forEach((doc) {
        rateNotifications.add(doc.data());
      });

      return rateNotifications;
    } catch (e) {
      print('Erro ao pegar notificações: $e');
      return [];
    }
  }

  Future<void> sendParticipantRate({
    required double rate,
    required String gigUid,
    required String ratedParticipantUid,
    required String comment,
  }) async {
    try {
      User? user = _auth.currentUser;
      String subkey1 = gigUid.substring(0, 10);
      String subkey2 = ratedParticipantUid.substring(0, 10);
      String subkey3 = user!.uid.substring(0, 10);
      String key = "$subkey1-$subkey2-$subkey3";

      DocumentReference<Map<String, dynamic>> rateUpdate =
          _firestore.collection('rating').doc(key);

      DocumentSnapshot<Map<String, dynamic>> rateDetail =
          await rateUpdate.get();

      Map<String, dynamic> data = rateDetail.data() ?? {};

      data = {
        'ratingUid': rateUpdate.id,
        'gigUid': gigUid,
        'ratedParticipantUid': ratedParticipantUid,
        'rate': rate,
        'rater': user.uid,
        'comment': comment,
      };

      await rateUpdate.set(data);
    } catch (e) {
      print("Erro ao criar/atualizar avaliação: $e");
    }
  }

  Future<Map<String, dynamic>> getRaterProfileData(String raterUid) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(raterUid).get();

        if (userSnapshot.exists) {
          return {
            'publicName': userSnapshot['publicName'],
            'profileImageUrl': userSnapshot['profileImageUrl'],
          };
        }
      }
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
    }
    return {};
  }

  Future<void> createRateNotificationsAndArchive(String gigId) async {
    final CollectionReference gigsCollection =
        FirebaseFirestore.instance.collection('gigs');
    final CollectionReference rateNotificationsCollection =
        FirebaseFirestore.instance.collection('rateNotification');
    final CollectionReference chatRoomsCollection =
        FirebaseFirestore.instance.collection('chat_rooms');

    // Obtém o documento da coleção 'gigs' pelo ID
    DocumentReference gigDocumentRef = gigsCollection.doc(gigId);
    DocumentSnapshot gigDocument = await gigDocumentRef.get();

    if (gigDocument.exists) {
      // Obtém os dados relevantes do documento 'gigs'
      String gigDescription = gigDocument['gigDescription'];
      List<String> gigParticipants =
          List<String>.from(gigDocument['gigParticipants']);
      // Atualiza o campo gigArchived para true
      await gigDocumentRef.update({'gigArchived': true});

      // Atualiza o campo gigArchived na coleção 'chat_rooms'
      await chatRoomsCollection
          .where('gigSubjectUid', isEqualTo: gigId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.update({'gigArchived': true});
        });
      });

      // Cria os rateNotifications apenas se houver mais de um participante
      if (gigParticipants.length > 1) {
        // Cria um novo documento para cada participante na coleção 'rateNotifications'
        for (String participantUid in gigParticipants) {
          // Cria um novo documento com um ID automático
          DocumentReference rateNotificationDocument =
              rateNotificationsCollection.doc();

          // Define os campos do novo documento
          Map<String, dynamic> data = {
            'gigDescription': gigDescription,
            'gigUid': gigId,
            'participantUid': participantUid,
            'rateNotificationUid': rateNotificationDocument.id,
          };

          // Adiciona os dados ao documento na coleção 'rateNotifications'
          await rateNotificationDocument.set(data);
        }
      }
    } else {
      print('Documento de gig não encontrado para o ID: $gigId');
    }
  }

  Future<Map<String, dynamic>> getUserRatingData(String userUid) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      // Referência para a coleção 'rating'
      CollectionReference ratingsCollection =
          FirebaseFirestore.instance.collection('rating');

      // Consulta para obter documentos onde 'ratedParticipantUid' é igual ao ID do usuário logado
      QuerySnapshot querySnapshot = await ratingsCollection
          .where('ratedParticipantUid', isEqualTo: userUid)
          .get();

      // Lista para armazenar os comments
      List<String> commentsList = [];
      List<String> raterList = [];

      // Variável para armazenar a soma dos valores de rate
      double totalRate = 0;

      // Iterar sobre os documentos encontrados
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        // Obter os dados de cada documento
        String comment = documentSnapshot['comment'];
        String rater = documentSnapshot['rater'];
        double rate = documentSnapshot['rate'];

        // Adicionar o comment à lista
        commentsList.add(comment);
        raterList.add(rater);

        // Adicionar o rate à soma total
        totalRate += rate;
      }

      // Calcular a média dos valores de rate
      double averageRate =
          querySnapshot.size > 0 ? totalRate / querySnapshot.size : 0;

      // Retorna um mapa com a média e a lista de comentários
      return {
        'media': averageRate,
        'comentarios': commentsList,
        'avaliadorId': raterList,
        'total': querySnapshot.size.toString(),
      };
    } else {
      // Retorna um mapa vazio se o usuário não estiver logado
      return {'media': 0, 'comentarios': []};
    }
  }
}
