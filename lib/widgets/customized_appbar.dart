import 'package:flutter/material.dart';

class CustomizedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomizedAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text("OTP"),
      elevation: 20,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
