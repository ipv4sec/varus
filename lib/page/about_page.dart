import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:varus/widgets/customized_appbar.dart';


class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomizedAppBar(),
      body: Html(data: '''
<div>
  <p>Copyright © by YuYuai. All rights reserved.</p>
</div>
      '''),
    );
  }
}
