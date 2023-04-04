import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import 'package:varus/widgets/customized_appbar.dart';

import '../view_model/about_view_model.dart';


class AboutPage extends StatelessWidget {
   AboutPage({Key? key}) : super(key: key);

   var _viewModel = Get.put(AboutPageViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizedAppBar(),
      body: Column(
        children: [
          Obx(() =>  Html(data: '${_viewModel.data.value.description}')),
        ],
      ),
    );
  }
}
