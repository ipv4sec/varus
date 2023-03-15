import 'package:flutter/material.dart';
import 'package:varus/page/configure_page.dart';
import 'package:varus/page/copyright_page.dart';
import 'package:varus/page/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: "Montserrat",
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: false),
      title: 'varus',
      initialRoute: "/",
      routes: {
        "/": (_)=> HomePage(),
        "/configure": (_)=> ConfigurePage(),
        "/copyright": (_)=> CopyrightPage(),
      },
      // home: HomePage(),
    );
  }
}



