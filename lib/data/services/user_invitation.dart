import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInvitation {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> userInvitation({
    required String guestUserUid,
    required String selectedGigUid,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentReference newUserInviteRef =
            _firestore.collection('userInvite').doc();

        await newUserInviteRef.set({
          /// definicoes da gig
          'inviteUid': newUserInviteRef.id,
          'inviteOwner': user.uid,
          'inviteStatus': 'Pendente',

          /// formularios da gig
          'guestUserId': guestUserUid,
          'gigUid': selectedGigUid,
        });
      }
    } catch (e) {
      print("Erro ao criar esta gig: $e");
    }
  }

  Future<List<Map<String, dynamic>>> listInvitesByGigAndOwner(
    String gigUid,
  ) async {
    try {
      User? user = _auth.currentUser;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('userInvite')
              .where('gigUid', isEqualTo: gigUid)
              .where('inviteOwner', isEqualTo: user!.uid)
              .get();

      List<Map<String, dynamic>> invites = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        String guestUserId = document['guestUserId'];

        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(guestUserId)
                .get();

        Map<String, dynamic> userInviteData = document.data();
        Map<String, dynamic> userData = {
          'publicName': userSnapshot['publicName'],
          'profileImageUrl': userSnapshot['profileImageUrl'],
          'category': userSnapshot['category'],
        };

        invites.add({
          'userInviteData': userInviteData,
          'userData': userData,
        });
      }

      return invites;
    } catch (e) {
      print('Erro ao listar convites: $e');
      return [];
    }
  }

  Future<void> myInvitationDelete(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('userInvite')
          .doc(documentId)
          .delete();
      print('Documento removido com sucesso!');
    } catch (e) {
      print('Erro ao remover documento: $e');
    }
  }
}