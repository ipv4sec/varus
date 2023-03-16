import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:varus/dao/varus_dao.dart';
import 'package:varus/service/varus_service.dart';
import 'dart:math' as math;

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

  static const _actionTitles = ['Create Post', 'Upload Photo', 'Upload Video'];


  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
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
                Text("OTP", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 18.0),),
                SizedBox(width: 10.0,),
                Text("v0.1.0", style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
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
                // trailing: CircleAvatar(
                //     child: Icon(
                //       Icons.account_tree,
                //       color: Colors.white,
                //     )),
                title: Text("Name: ${snapshot.data?[index].name}"),
                subtitle:
                    Text("Description: ${snapshot.data?[index].description}"),
                onTap: () async {
                  await VarusService.instance
                      .deleteVarus(snapshot.data![index].id!);
                  vs = await VarusService.instance.queryAllVarus();
                  _streamController.sink.add(vs);
                  Fluttertoast.showToast(
                    backgroundColor: Colors.black54,
                      msg: 'removed :${snapshot.data![index].id!}');
                },
              );
            },
          );
        },
      ),
      floatingActionButton:
      // FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () async {
      //     // VarusDao.instance.createVarus(Varus(name: "name", value: "value", description: "description"));
      //     // var vs = await VarusDao.instance.queryAllVarus();
      //     // print(vs.toString());
      //     var varus =
      //         Varus(name: "name", value: "value", description: "description");
      //     var id = await VarusService.instance.createVarus(varus);
      //     varus.id = id;
      //     vs.add(varus);
      //     _streamController.sink.add(vs);
      //   },
      // ),
      ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _showAction(context, 0),
            icon: const Icon(Icons.format_size),
          ),
          ActionButton(
            onPressed: () async {
              ImagePicker picker = ImagePicker();
              XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
              );
              print(image);
              // if (image != null) {
              // if (await controller.analyzeImage(image.path)) {
              // if (!mounted) return;
              // ScaffoldMessenger.of(context).showSnackBar(
              // const SnackBar(
              // content: Text('Barcode found!'),
              // backgroundColor: Colors.green,
              // ),
              // );
              // } else {
              // if (!mounted) return;
              // ScaffoldMessenger.of(context).showSnackBar(
              // const SnackBar(
              // content: Text('No barcode found!'),
              // backgroundColor: Colors.red,
              // ),
              // );
              // }
              // }

    },
            icon: const Icon(Icons.insert_photo),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 2),
            icon: const Icon(Icons.videocam),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
    i < count;
    i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4.0,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}