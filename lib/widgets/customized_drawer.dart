import 'package:flutter/material.dart';

class CustomizedDrawer extends StatelessWidget {
  const CustomizedDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.all(0.0), children: <Widget>[
      DrawerHeader(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Row(
            children: [
              Text(
                "VARUS OTP",
                style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 18.0),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                "v0.1.0",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      ),
      ListTile(
        leading: Icon(Icons.adb_sharp),
        title: Text('调试'),
        onTap: () {
          Navigator.pushNamed(context, "/debug");
        },
      ),
      ListTile(
        leading: Icon(Icons.info_rounded),
        title: Text('关于'),
        onTap: () {
          Navigator.pushNamed(context, "/about");
        },
      ),
      ListTile(
        leading: Icon(Icons.messenger_sharp),
        title: Text('反馈'),
        onTap: () async {
          Navigator.pushNamed(context, "/feedback");
        },
      ),
    ]));
  }
}
