import 'package:flutter/material.dart';
import 'package:freegig_app/common/themeapp.dart';
import 'package:page_transition/page_transition.dart';

class HomeCustomCard extends StatefulWidget {
  final String imgCard;
  final String buttonText;
  final Widget destination;

  HomeCustomCard(
      {required this.buttonText,
      required this.destination,
      required this.imgCard});

  @override
  State<HomeCustomCard> createState() => _HomeCustomCardState();
}

class _HomeCustomCardState extends State<HomeCustomCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.grey, width: 0.3),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: Offset(2, 2),
              blurRadius: 1,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                widget.imgCard,
                width: 120,
              ),
            )),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: Offset(2, 2),
                      blurRadius: 1,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            duration: Duration(milliseconds: 500),
                            type: PageTransitionType.bottomToTop,
                            child: widget.destination,
                          ),
                        );
                      },
                      child: Text(
                        widget.buttonText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
