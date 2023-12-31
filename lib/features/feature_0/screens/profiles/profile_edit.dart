import 'package:flutter/material.dart';
import 'package:freegig_app/common/functions/navigation.dart';
import 'package:freegig_app/services/current_user/current_user_service.dart';
import 'package:freegig_app/common/themeapp.dart';
import 'package:freegig_app/features/feature_0/screens/profiles/profile_edit_form.dart';
import 'package:freegig_app/services/auth/auth_service.dart';
import 'package:iconsax/iconsax.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  bool isSwitched = true;

  late String _publicName = "";
  late String _category = "";

  @override
  void initState() {
    super.initState();
    _carregarDadosDoUsuario(); // carrega os dados
  }

  Future<void> _carregarDadosDoUsuario() async {
    try {
      Map<String, dynamic> userData =
          await UserDataService().getCurrentUserData();

      setState(() {
        _publicName = userData['publicName'];
        _category = userData['category'];
      });
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e"); // Trate erros, se houverem
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Perfil',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 19.0,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuthService().logOut(context);
              },
              icon: Icon(Iconsax.logout_1))
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "Olá, $_publicName",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "$_category",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "Aprimore a sua experiência no FreeGIG completando o seu perfil.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "Personalize suas informações para usufruir ao máximo dos recursos oferecidos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  navigationFadeTo(
                      context: context, destination: ProfileEditForm());
                },
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    "Completar perfil",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
