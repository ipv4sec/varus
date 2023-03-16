import 'package:flex_color_scheme/flex_color_scheme.dart';
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
    var theme = FlexThemeData.light(
      fontFamily: "Montserrat",
        useMaterial3: false,
        scheme: FlexScheme.materialBaseline);

    return MaterialApp(
      theme: theme,
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



