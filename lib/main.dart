import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:varus/page/about_page.dart';
import 'package:varus/page/append_page.dart';
import 'package:varus/page/camera_page.dart';
import 'package:varus/page/debug_page.dart';
import 'package:varus/page/feedback_page.dart';
import 'package:varus/page/home_page.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
        (options) {
      options.dsn =
      'https://ef68d0f454ce4fe4a0b92e00e349224b@o4504851599720448.ingest.sentry.io/4504851603849216';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = FlexThemeData.light(
        fontFamily: "Montserrat",
        useMaterial3: true,
        scheme: FlexScheme.materialBaseline);

    return MaterialApp(
      theme: theme,
      title: '二步验证',
      initialRoute: "/",
      routes: {
        "/": (_) => HomePage(),
        "/debug": (_) => DebugPage(),
        "/about": (_) => AboutPage(),
        "/camera": (_) => CameraPage(),
        "/append": (_) => AppendPage(),
        "/feedback": (_) => FeedBackPage(),
      },
    );
  }
}
