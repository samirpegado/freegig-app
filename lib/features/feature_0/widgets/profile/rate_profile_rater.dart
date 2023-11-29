import 'package:flutter/material.dart';
import 'package:freegig_app/data/services/user_rate.dart';

class GetProfileRater extends StatefulWidget {
  final String profileUid;
  final String comments;
  const GetProfileRater(
      {super.key, required this.profileUid, required this.comments});

  @override
  State<GetProfileRater> createState() => _GetProfileRaterState();
}

class _GetProfileRaterState extends State<GetProfileRater> {
  String publicName = "";
  String profileImageUrl = "";
  @override
  void initState() {
    super.initState();
    _loadRatingData();
  }

  Future<void> _loadRatingData() async {
    try {
      Map<String, dynamic> raterData =
          await UserRateService().getRaterProfileData(widget.profileUid);

      setState(() {
        publicName = raterData['publicName'];
        profileImageUrl = raterData['profileImageUrl'];
      });
    } catch (e) {
      print("Erro ao carregar dados da avaliação: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: profileImageUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                profileImageUrl,
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              ),
            )
          : CircularProgressIndicator(),
      title: Text(
        widget.comments,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
      ),
      subtitle: Text(
        publicName,
      ),
    );
  }
}
