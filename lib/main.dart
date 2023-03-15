import 'package:flutter/material.dart';
// import 'package:varus/dao/varus_dao.dart';
import 'package:varus/page/home_page.dart';
// import 'package:varus/service/varus_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: "Montserrat", colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange), useMaterial3: false),
      title: 'varus',
      home: HomePage(),
    );
  }
}



