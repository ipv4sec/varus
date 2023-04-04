import 'package:flutter/material.dart';
import 'package:varus/dao/varus_dao.dart';
import 'package:varus/service/varus_service.dart';
import 'package:varus/utils/toast_utils.dart';

import 'package:varus/widgets/customized_appbar.dart';

class FillingPage extends StatefulWidget {
  const FillingPage({Key? key}) : super(key: key);

  @override
  State<FillingPage> createState() => _FillingPageState();
}

class _FillingPageState extends State<FillingPage> {

  var _titleTextEditingController = TextEditingController();
  var _secretTextEditingController = TextEditingController();
  var _descriptionTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizedAppBar(),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _titleTextEditingController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.read_more_sharp),
                labelText: "title",
              ),
            ),
            TextField(
              controller: _secretTextEditingController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.water_drop_outlined),
                labelText: "secret",
              ),
            ),
            TextField(
              controller: _descriptionTextEditingController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.add_chart_sharp),
                labelText: "description",
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_titleTextEditingController.text.length == 0 ||
              _secretTextEditingController.text.length == 0 ||
              _descriptionTextEditingController.text.length == 0) {
            toast("保存成功");
            return;
          }
          var varus =
              Varus(
                  name: _titleTextEditingController.text,
                  secret: _secretTextEditingController.text,
                  description: _descriptionTextEditingController.text);
          await VarusService.instance.createVarus(varus);
          toast("保存成功");
          Navigator.pushNamed(context, "/");
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.save_alt_outlined),
        label: const Text("保存条目"),
      ),
    );
  }
}
