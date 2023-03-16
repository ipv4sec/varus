import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:varus/widgets/customized_appbar.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
    );
  }
}




