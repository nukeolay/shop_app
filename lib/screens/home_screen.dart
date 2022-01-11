import 'package:flutter/material.dart';

import '../widgets/custom_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/home-screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 30,
                right: 30,
              ),
              child: Image(
                image: AssetImage('assets/images/logo_named.png'),
              )),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text('Home, Sweet Home'),
        ),
        bottomNavigationBar: const CustomNavigationBar(),
      ),
    );
  }
}
