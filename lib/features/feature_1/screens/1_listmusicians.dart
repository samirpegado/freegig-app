// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:freegig_app/features/feature_1/widgets/musician_usercategorybutton.dart';
import 'package:freegig_app/features/feature_1/widgets/musician_usercitybutton.dart';
import 'package:freegig_app/features/feature_0/navigation_menu.dart';
import 'package:freegig_app/features/feature_1/widgets/musicians_cardsroll.dart';
import 'package:freegig_app/common/themeapp.dart';
import 'package:page_transition/page_transition.dart';

class ListMusicians extends StatefulWidget {
  final Stream<List<Map<String, dynamic>>> profileListFunction;
  final String city;
  final String category;
  final bool profileStatus = true;
  const ListMusicians({
    super.key,
    required this.profileListFunction,
    required this.city,
    required this.category,
  });

  @override
  _ListMusiciansState createState() => _ListMusiciansState();
}

class _ListMusiciansState extends State<ListMusicians> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(
          context,
          PageTransition(
            duration: Duration(milliseconds: 300),
            type: PageTransitionType.fade,
            childCurrent: ListMusicians(
                profileListFunction: widget.profileListFunction,
                city: widget.city,
                category: widget.category),
            child: NavigationMenu(),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Músicos disponíveis',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 19.0,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    child: UserCityButtonProfile(
                      city: widget.city,
                      category: widget.category,
                    ),
                  ),
                  Expanded(
                    child: MusicianCategoryButton(
                        city: widget.city, category: widget.category),
                  ),
                  SizedBox(width: 20),
                ],
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    HomeCardsRoll(
                      profileListFunction: widget.profileListFunction,
                    ),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
