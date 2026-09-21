import 'package:flutter/material.dart';
import 'package:varus/dao/varus_dao.dart';
import 'package:varus/service/varus_service.dart';
import 'package:varus/utils/toast_utils.dart';

import 'package:varus/widgets/customized_appbar.dart';

class FillingPage extends StatefulWidget {
  const FillingPage({
    Key? key,
    this.existing,
    this.initialTitle,
    this.initialSecret,
    this.initialDescription,
    this.initialPeriod,
    this.initialDigits,
    this.initialAlgorithm,
    this.initialType,
    this.initialCounter,
  }) : super(key: key);

  final Varus? existing;
  final String? initialTitle;
  final String? initialSecret;
  final String? initialDescription;
  final int? initialPeriod;
  final int? initialDigits;
  final String? initialAlgorithm;
  final String? initialType;
  final int? initialCounter;

  @override
  State<FillingPage> createState() => _FillingPageState();
}

class _FillingPageState extends State<FillingPage> {

  var _titleTextEditingController = TextEditingController();
  var _secretTextEditingController = TextEditingController();
  var _descriptionTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleTextEditingController.text = existing.name;
      _secretTextEditingController.text = existing.secret;
      _descriptionTextEditingController.text = existing.description;
    } else {
      _titleTextEditingController.text = widget.initialTitle ?? '';
      _secretTextEditingController.text = widget.initialSecret ?? '';
      _descriptionTextEditingController.text =
          widget.initialDescription ?? '';
    }
  }

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
            toast("请填写完整");
            return;
          }
          final existing = widget.existing;
          if (existing != null) {
            existing.name = _titleTextEditingController.text;
            existing.secret = _secretTextEditingController.text;
            existing.description = _descriptionTextEditingController.text;
            await VarusService.instance.updateVarus(existing);
          } else {
            var varus = Varus(
                name: _titleTextEditingController.text,
                secret: _secretTextEditingController.text,
                description: _descriptionTextEditingController.text,
                period: widget.initialPeriod,
                digits: widget.initialDigits,
                algorithm: widget.initialAlgorithm,
                type: widget.initialType,
                counter: widget.initialCounter);
            await VarusService.instance.createVarus(varus);
          }
          toast("保存成功");
          Navigator.pushReplacementNamed(context, "/");
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.save_alt_outlined),
        label: Text(widget.existing != null ? "保存修改" : "保存条目"),
      ),
    );
  }
}
