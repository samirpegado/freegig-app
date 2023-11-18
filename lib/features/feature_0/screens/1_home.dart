import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:freegig_app/features/feature_0/widgets/gigs/createnewgigform.dart';
import 'package:freegig_app/features/feature_0/widgets/home/home_customcard.dart';
import 'package:freegig_app/features/feature_0/widgets/home/home_pageview.dart';
import 'package:freegig_app/common_widgets/themeapp.dart';
import 'package:freegig_app/features/feature_1/screens/1_listmusicians.dart';
import 'package:freegig_app/features/feature_2/screens/1_listgigs.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          SafeArea(
            child: Container(
              height: 420,
              // color: primaryColor,
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 370,
                    child: Image.asset(
                      'assets/images/backimg.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 370,
                      viewportFraction: 1,
                      initialPage: 0,
                      autoPlay: true,
                    ),
                    items: [
                      'assets/images/backimg.png',
                      'assets/images/backimg2.png',
                      'assets/images/backimg3.png',
                      'assets/images/backimg4.png',
                    ].map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: double.infinity,
                            height: 400,
                            child: Image.asset(
                              i,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Positioned(
                    bottom: 10,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        HomeCustomCard(
                          buttonText: "Encontrar músicos",
                          destination: ListMusicians(),
                          imgCard: 'assets/images/musicos.png',
                        ),
                        HomeCustomCard(
                          buttonText: "Encontrar GIGs",
                          destination: ListGigs(),
                          imgCard: 'assets/images/encontrar.png',
                        ),
                        HomeCustomCard(
                          buttonText: "Criar Gigs",
                          destination: CreateNewGig(),
                          imgCard: 'assets/images/criar.png',
                        ),
                        SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: HomeAgenda(),
          )
        ],
      ),
    );
  }
}
