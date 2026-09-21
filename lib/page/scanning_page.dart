import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

import 'package:varus/page/filling_page.dart';
import 'package:varus/utils/toast_utils.dart';
import 'package:varus/widgets/customized_appbar.dart';

class ScanningPage extends StatefulWidget {
  const ScanningPage({Key? key}) : super(key: key);

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> {
  MobileScannerController? cameraController;
  bool _navigated = false;

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
        controller: cameraController,
        onDetect: (capture) {
          if (_navigated) {
            return;
          }
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isEmpty || barcodes.first.rawValue == null) {
            return;
          }
          _navigated = true;
          debugPrint('Barcode found! ${barcodes.first.rawValue}');
          cameraController?.stop();
          _openFilling(barcodes.first.rawValue!);
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
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if (image == null) {
                return;
              }
              try {
                final capture = await cameraController?.analyzeImage(image.path);
                final rawValue = (capture?.barcodes.isNotEmpty ?? false)
                    ? capture!.barcodes.first.rawValue
                    : null;
                if (rawValue == null) {
                  toast("未识别到二维码");
                  return;
                }
                _openFilling(rawValue);
              } catch (e) {
                debugPrint('analyzeImage error: $e');
                toast("识别失败");
              }
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
              Navigator.pushNamed(context, "/filling");
            },
            backgroundColor: Colors.teal,
            icon: const Icon(Icons.add_card_sharp),
            label: const Text("手动添加"),
          )
        ]
    ),
    );
  }
  void _openFilling(String rawValue) {
    final parsed = _parseOtpAuth(rawValue);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FillingPage(
          initialTitle: parsed.title,
          initialSecret: parsed.secret,
          initialDescription: parsed.description,
          initialPeriod: parsed.period,
          initialDigits: parsed.digits,
          initialAlgorithm: parsed.algorithm,
          initialType: parsed.type,
          initialCounter: parsed.counter,
        ),
      ),
    );
  }

  ({
    String title,
    String secret,
    String description,
    int period,
    int digits,
    String algorithm,
    String type,
    int counter,
  }) _parseOtpAuth(String rawValue) {
    final uri = Uri.tryParse(rawValue);
    if (uri == null || !uri.isScheme('otpauth') || uri.path.length < 2) {
      return (
        title: rawValue,
        secret: '',
        description: '',
        period: 30,
        digits: 6,
        algorithm: 'SHA1',
        type: 'totp',
        counter: 0,
      );
    }
    final label = Uri.decodeFull(uri.path.substring(1));
    final issuer = uri.queryParameters['issuer'];
    var title = label;
    var description = issuer ?? '';
    final colon = label.indexOf(':');
    if (colon != -1) {
      title = label.substring(colon + 1).trim();
      description = issuer ?? label.substring(0, colon).trim();
    }
    final period = int.tryParse(uri.queryParameters['period'] ?? '') ?? 30;
    final digits = int.tryParse(uri.queryParameters['digits'] ?? '') ?? 6;
    final algorithm =
        (uri.queryParameters['algorithm'] ?? 'SHA1').toUpperCase();
    final type = uri.host.toLowerCase() == 'hotp' ? 'hotp' : 'totp';
    final counter =
        int.tryParse(uri.queryParameters['counter'] ?? '') ?? 0;
    return (
      title: title,
      secret: uri.queryParameters['secret'] ?? '',
      description: description,
      period: period,
      digits: digits,
      algorithm: algorithm,
      type: type,
      counter: counter,
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}




