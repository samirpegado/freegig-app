import 'package:flutter/material.dart';
import 'package:freegig_app/classes/formatdate.dart';
import 'package:freegig_app/common/functions/navigation.dart';
import 'package:freegig_app/common/themeapp.dart';
import 'package:freegig_app/common/widgets/participants_list.dart';
import 'package:freegig_app/services/gigs/gigs_service.dart';
import 'package:freegig_app/features/chat/gig_chat_page.dart';
import 'package:freegig_app/features/feature_0/navigation_menu.dart';
import 'package:iconsax/iconsax.dart';

class ParticipatingGigInfo extends StatefulWidget {
  final Map<String, dynamic> gig;

  const ParticipatingGigInfo({super.key, required this.gig});

  @override
  State<ParticipatingGigInfo> createState() => _ParticipatingGigInfoState();
}

class _ParticipatingGigInfoState extends State<ParticipatingGigInfo> {
  late Future<List<Map<String, dynamic>>> participantsData;
  late bool gigStatus = widget.gig['gigCompleted'];
  late bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              navigationFadeTo(
                  context: context,
                  destination:
                      GigChatPage(gigSubjectUid: widget.gig['gigUid']));
            },
            icon: Icon(
              Iconsax.messages,
              color: Colors.blue,
            ),
          ),
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title:
                        Text('Atenção!', style: TextStyle(color: Colors.red)),
                    content: Text('Tem certeza que deseja desistir da GIG?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          child: Text("Cancelar",
                              style: TextStyle(color: Colors.black))),
                      isLoading
                          ? CircularProgressIndicator()
                          : TextButton(
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await GigsDataService()
                                    .leaveGig(gigUid: widget.gig['gigUid']);

                                navigationFadeTo(
                                    context: context,
                                    destination: NavigationMenu(navPage: 1));
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: Text("Confirmar",
                                  style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
              icon: Icon(
                Iconsax.profile_remove,
                color: Colors.red,
              ))
        ],
        title: Text(
          'Participando',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 19.0,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                "${widget.gig['gigDescription']}",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.green),
              ),
              Text(
                FormatDate().formatDateString(widget.gig['gigDate']),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.green),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Icon(
                    gigStatus ? Iconsax.lock : Iconsax.unlock,
                    size: 25,
                    color: gigStatus ? Colors.green : Colors.black,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      gigStatus ? 'Fechada' : 'Aberta',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Iconsax.device_message,
                    size: 25,
                    color: Colors.green,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.gig['gigDetails'],
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Iconsax.music,
                    size: 25,
                    color: Colors.green,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "${widget.gig['gigCategorys'].join(', ')}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Iconsax.money,
                    size: 25,
                    color: Colors.green,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.gig['gigCache'],
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Iconsax.clock,
                    size: 25,
                    color: Colors.green,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "${widget.gig['gigInitHour']}h - ${widget.gig['gigFinalHour']}h",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Iconsax.location,
                    size: 25,
                    color: Colors.green,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.gig['gigAdress'],
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                "Participantes: ",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.green),
              ),
              SizedBox(height: 6),
              ParticipantList(gigUid: widget.gig['gigUid'])
            ],
          ),
        ),
      ),
    );
  }
}
