// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:freegig_app/common/widgets/gigs_card.dart';
import 'package:freegig_app/common/functions/themeapp.dart';
import 'package:freegig_app/services/archive/archive_service.dart';
import 'package:freegig_app/features/feature_0/widgets/gigs/archived_more_info.dart';

class ArchivedGigs extends StatefulWidget {
  @override
  State<ArchivedGigs> createState() => _ArchivedGigsState();
}

class _ArchivedGigsState extends State<ArchivedGigs> {
  late Stream<List<Map<String, dynamic>>> gigsDataList;

  @override
  void initState() {
    super.initState();
    gigsDataList = GigsArchived().getMyAllArchivedGigsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'GIGs arquivadas',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 19.0,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: gigsDataList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else {
                  List<Map<String, dynamic>> gigs = snapshot.data ?? [];

                  if (gigs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(
                        child: Text(
                          'Nenhuma gig encontrada',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: gigs.map((gig) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 5),
                        child: InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ArchivedMoreInfo(gig: gig));
                            },
                            child: CommonGigsCard(
                              gig: gig,
                              moneyColor: Colors.black54,
                            )),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}