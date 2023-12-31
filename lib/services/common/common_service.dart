import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freegig_app/classes/datetime_convert.dart';

class CommonServices extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  //Pega dados de usuários
  Future<Map<String, dynamic>> getGigUserData(String userUid) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userUid).get();

    return userSnapshot.data() as Map<String, dynamic>;
  }

  //Pega os dados da gig e do usuário que criou a gig
  Future<List<Map<String, dynamic>>> processGigData(
      QuerySnapshot gigsSnapshot) async {
    List<Map<String, dynamic>> gigsDataList = [];

    for (QueryDocumentSnapshot gigDocument in gigsSnapshot.docs) {
      Map<String, dynamic> gigData = gigDocument.data() as Map<String, dynamic>;
      String ownerId = gigData['gigOwner'];

      Map<String, dynamic> userData = await getGigUserData(ownerId);

      gigsDataList.add({
        ...gigData,
        'profileImageUrl': userData['profileImageUrl'],
        'publicName': userData['publicName'],
        'category': userData['category'],
      });
    }

    gigsDataList.sort((a, b) {
      DateTime dateA = DateTimeConvert().parseDate(a['gigDate']);
      DateTime dateB = DateTimeConvert().parseDate(b['gigDate']);

      return dateA.compareTo(dateB);
    });

    return gigsDataList;
  }
}
