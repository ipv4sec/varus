import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

import 'package:varus/widgets/customized_appbar.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController? cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      returnImage: true,
        detectionSpeed: DetectionSpeed.noDuplicates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Mobile Scanner'),
      //   actions: [
      //     IconButton(
      //       color: Colors.white,
      //       icon: ValueListenableBuilder(
      //         valueListenable: cameraController!.torchState,
      //         builder: (context, state, child) {
      //           switch (state as TorchState) {
      //             case TorchState.off:
      //               return const Icon(Icons.flash_off, color: Colors.grey);
      //             case TorchState.on:
      //               return const Icon(Icons.flash_on, color: Colors.yellow);
      //           }
      //         },
      //       ),
      //       iconSize: 32.0,
      //       onPressed: () => cameraController!.toggleTorch(),
      //     ),
      //     IconButton(
      //       color: Colors.white,
      //       icon: ValueListenableBuilder(
      //         valueListenable: cameraController!.cameraFacingState,
      //         builder: (context, state, child) {
      //           switch (state as CameraFacing) {
      //             case CameraFacing.front:
      //               return const Icon(Icons.camera_front);
      //             case CameraFacing.back:
      //               return const Icon(Icons.camera_rear);
      //           }
      //         },
      //       ),
      //       iconSize: 32.0,
      //       onPressed: () => cameraController!.switchCamera(),
      //     ),
      //   ],
      // ),
        appBar: CustomizedAppBar(),
      body: MobileScanner(
        // fit: BoxFit.contain,
        controller: cameraController,
        // onScannerStarted: ,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          // final Uint8List? image = capture.image;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
            // break;
            cameraController!.stop();
          }
          // Navigator.pushNamed(context, "/");

        },
      ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "1",
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              // Pick an image
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              print(image);
              Navigator.pushNamed(context, "/append");
              // Navigator.of(context).pushNamed();
            },
            backgroundColor: Colors.teal,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text("图库图片"),
          ),
          SizedBox(
            height: 20.0,
          ),
          FloatingActionButton.extended(
            heroTag: "2",
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
            label: const Text("手动添加"),
          )
        ]
    ),
    );
  }
  @override
  void dispose() {
    cameraController?.stop();
    super.dispose();
  }
}




