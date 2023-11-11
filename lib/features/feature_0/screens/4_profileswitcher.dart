import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freegig_app/features/feature_0/widgets/profile/profile_complete.dart';
import 'package:freegig_app/features/feature_0/widgets/profile/profile_edit.dart';

class ProfileSwitcher extends StatefulWidget {
  @override
  _ProfileSwitcherState createState() => _ProfileSwitcherState();
}

class _ProfileSwitcherState extends State<ProfileSwitcher> {
  bool? _profileComplete;

  @override
  void initState() {
    super.initState();
    _loadProfileCompleteStatus();
  }

  Future<void> _loadProfileCompleteStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          _profileComplete = userSnapshot['profileComplete'];
        });
      }
    } catch (e) {
      print("Erro ao carregar status de profileComplete: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profileComplete == null) {
      // Pode exibir um indicador de carregamento ou fazer qualquer outra coisa enquanto carrega
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return _profileComplete! ? ProfileComplete() : ProfileEdit();
    }
  }
}
