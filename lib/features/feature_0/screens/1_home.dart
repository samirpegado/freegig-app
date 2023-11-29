import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:freegig_app/data/services/gigs_data_services.dart';
import 'package:freegig_app/data/services/profiles_data_service.dart';
import 'package:freegig_app/data/services/user_data_service.dart';
import 'package:freegig_app/features/feature_0/widgets/home/home_customcard.dart';
import 'package:freegig_app/features/feature_0/widgets/home/home_pageview.dart';
import 'package:freegig_app/common_widgets/themeapp.dart';
import 'package:freegig_app/features/feature_1/screens/1_listmusicians.dart';
import 'package:freegig_app/features/feature_2/screens/1_listgigs.dart';
import 'package:iconsax/iconsax.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String _city = "";
  late String _category = "";
  late String _profileCategory = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      Map<String, dynamic> userData =
          await UserDataService().getCityProfileData();

      setState(() {
        _city = userData['city'];
        _category = userData['category'];
        _profileCategory = 'Todos';
      });
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          SafeArea(
            child: Container(
              height: 420,
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
                        SizedBox(width: 30),
                        HomeCustomCard(
                          buttonText: "Buscar músicos",
                          destination: ListMusicians(
                            profileListFunction: ProfileDataService()
                                .getActiveUserProfileStream(
                                    category: _profileCategory, city: _city),
                            city: _city,
                            category: _profileCategory,
                          ),
                          imgCard: 'assets/images/musicos.png',
                        ),
                        SizedBox(width: 30),
                        HomeCustomCard(
                          buttonText: "Buscar GIGs",
                          destination: ListGigs(
                            dataListFunction: GigsDataService()
                                .getCityActiveUserGigsStream(
                                    city: _city, category: _category),
                            city: _city,
                            category: _category,
                          ),
                          imgCard: 'assets/images/encontrar.png',
                        ),
                        SizedBox(width: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 30),
                    Icon(Iconsax.calendar5,
                        color: Color.fromARGB(255, 55, 158, 58)),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Suas GIGs",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 19.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(child: HomeAgenda()),
              ],
            ),
          )
        ],
      ),
    );
  }
}
