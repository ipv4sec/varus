import 'dart:async';

import 'package:flutter/material.dart';
import 'package:varus/dao/varus_dao.dart';
import 'package:varus/service/varus_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Varus> vs = [];
  var _streamController = StreamController<List<Varus>>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    vs = await VarusService.instance.queryAllVarus();
    print(vs);
    _streamController.sink.add(vs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(padding: EdgeInsets.all(0.0), children: <Widget>[
        DrawerHeader(
          child: Padding(
            padding: EdgeInsets.only(top: 100.0),
            child: Row(
              children: [
                Text("OTP", style: TextStyle(color: Colors.white, fontSize: 18.0),),
                SizedBox(width: 10.0,),
                Text("v0.1.0", style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
          decoration: BoxDecoration(color: Colors.deepOrange),
        ),
           ListTile(
             leading: Icon(Icons.settings),
             title: Text('Configure'),
             onTap: () {
               Navigator.pushNamed(context, "/configure");
             },
           ),
           ListTile(
             leading: Icon(Icons.ac_unit),
             title: Text('Copyright'),
             onTap: () {
               Navigator.pushNamed(context, "/copyright");
             },
           ),
      ])),
      appBar: AppBar(
        centerTitle: true,
        title: Text("OTP"),
        elevation: 50,
      ),
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
              return ListTile(
                leading: CircleAvatar(
                    child: Icon(
                  Icons.account_tree,
                  color: Colors.white,
                )),
                title: Text("Name: ${snapshot.data?[index].name}"),
                subtitle:
                    Text("Description: ${snapshot.data?[index].description}"),
                onTap: () async {
                  await VarusService.instance
                      .deleteVarus(snapshot.data![index].id!);
                  vs = await VarusService.instance.queryAllVarus();
                  _streamController.sink.add(vs);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // VarusDao.instance.createVarus(Varus(name: "name", value: "value", description: "description"));
          // var vs = await VarusDao.instance.queryAllVarus();
          // print(vs.toString());
          var varus =
              Varus(name: "name", value: "value", description: "description");
          var id = await VarusService.instance.createVarus(varus);
          varus.id = id;
          vs.add(varus);
          _streamController.sink.add(vs);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }
}
