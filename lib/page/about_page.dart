import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:varus/widgets/customized_appbar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizedAppBar(),
      body: Html(data: '''
<div>
  <p>Copyright © by YuYuai. All rights reserved.</p>
</div>
      '''),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, "/camera");
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.home_work_outlined),
        label: const Text("返回"),
      ),
    );
  }
}
