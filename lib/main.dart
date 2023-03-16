import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:varus/page/about_page.dart';
import 'package:varus/page/append_page.dart';
import 'package:varus/page/debug_page.dart';
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
      title: 'OTP',
      initialRoute: "/",
      routes: {
        "/": (_) => HomePage(),
        "/debug": (_) => DebugPage(),
        "/about": (_) => AboutPage(),
        "/append": (_) => AppendPage(),
      },
    );
  }
}
