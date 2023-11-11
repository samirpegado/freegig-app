import 'package:flutter/material.dart';
import 'package:freegig_app/common_widgets/themeapp.dart';

class HomeCustomCard extends StatelessWidget {
  final String imgCard;
  final String buttonText;
  final Widget destination;

  HomeCustomCard(
      {required this.buttonText,
      required this.destination,
      required this.imgCard});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115,
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
              imgCard,
              width: 120,
              //fit: BoxFit.cover,
            ),
          )),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => destination));
              },
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}