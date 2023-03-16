import 'dart:async';

import 'package:flutter/material.dart';

// import 'package:image_picker/image_picker.dart';
import 'package:varus/dao/varus_dao.dart';
import 'package:varus/service/varus_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:varus/widgets/customized_appbar.dart';
import 'package:varus/widgets/customized_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Varus> vs = [];
  var _streamController = StreamController<List<Varus>>();

  MobileScannerController? _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
        returnImage: false, detectionSpeed: DetectionSpeed.noDuplicates);
    _init();
  }

  Future<void> _init() async {
    vs = await VarusService.instance.queryAllVarus();
    // print(vs);
    _streamController.sink.add(vs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomizedDrawer(),
      appBar: CustomizedAppBar(),
      body: StreamBuilder<List<Varus>>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Text("Loading");
          }
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (BuildContext context, int index) => Divider(
              height: 0.1,
              color: Color(0xFFF9FBE7),
            ),
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                  background: Container(color: Colors.deepOrange,),
                  onDismissed: (direction) {
                    vs.removeAt(index);
                    _streamController.sink.add(vs);
                    // 展示一个 snackbar！(Then show a snackbar!)
                    // Scaffold.of(context)
                    //     .showSnackBar(SnackBar(content: Text("$item dismissed")));
                  },
                  key: Key(vs[index].id.toString()),
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Icon(
                      Icons.account_tree,
                      color: Colors.white,
                    )),
                    // trailing: CircleAvatar(
                    //     child: Icon(
                    //       Icons.account_tree,
                    //       color: Colors.white,
                    //     )),
                    title: Text("Name: ${snapshot.data?[index].name}"),
                    subtitle: Text(
                        "Description: ${snapshot.data?[index].description}"),
                    onTap: () async {
                      await VarusService.instance
                          .deleteVarus(snapshot.data![index].id!);
                      vs = await VarusService.instance.queryAllVarus();
                      _streamController.sink.add(vs);
                    },
                  ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // VarusDao.instance.createVarus(Varus(name: "name", value: "value", description: "description"));
          // var vs = await VarusDao.instance.queryAllVarus();
          // print(vs.toString());
          // var varus =
          //     Varus(name: "name", value: "value", description: "description");
          // var id = await VarusService.instance.createVarus(varus);
          // varus.id = id;
          // vs.add(varus);
          // _streamController.sink.add(vs);
          Navigator.pushNamed(context, "/append");
          // Navigator.of(context).pushNamed();
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add_card_sharp),
        label: const Text("Append"),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
    _cameraController?.dispose();
  }
}
