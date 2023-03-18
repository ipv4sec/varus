import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:varus/widgets/customized_appbar.dart';


class FeedBackPage extends StatefulWidget {
  const FeedBackPage({Key? key}) : super(key: key);

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomizedAppBar(),
      body: Column(
        children: [
          Html(data: '''
<div>
  <p>Copyright © by YuYuai. All rights reserved.</p>
</div>
      ''')
        ],
      ),
    );
  }
}
