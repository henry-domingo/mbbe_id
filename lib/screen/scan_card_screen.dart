import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mbbe_id/model/id_nfc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../helpers.dart';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen>
    with WidgetsBindingObserver {
  //NFC
  var isAvailable = false;
  var isScanningNFC = false;
  IdNfc? dataNFC;

  //QR
  var isScanningQR = false;
  IdNfc? dataQR;

  final MobileScannerController controller = MobileScannerController(
      // required options for the scanner
      );

  StreamSubscription<Object?>? _subscription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _startScanningQR();
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        _stopScanningQR();
    }
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    final capturedQR = barcodes.barcodes.firstOrNull;
    if (capturedQR != null) {
      final encryptedText = capturedQR.rawValue ?? '';
      dataQR = IdNfc.fromJson(jsonDecode(decryptTextFromBase64(encryptedText)));
      _stopScanningQR();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkNFC();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);
  }

  void _startScanningQR() {
    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    unawaited(controller.start());
    setState(() {
      isScanningQR = true;
    });
  }

  void _stopScanningQR() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(controller.stop());
    setState(() {
      isScanningQR = false;
    });
  }

  Future<void> _checkNFC() async {
    isAvailable = await NfcManager.instance.isAvailable();
  }

  void _startScanning() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        Ndef? ndef = Ndef.from(tag);
        if (ndef == null) {
          setState(() {
            isScanningNFC = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Tag is not NDEF.')));
          return;
        }
        try {
          final data = await ndef.read();
          final record = data.records.firstOrNull;
          if (record == null) {
            if (mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('No records.')));
            }
            setState(() {
              isScanningNFC = false;
            });
            return;
          }
          setState(() {
            isScanningNFC = false;
            dataNFC = IdNfc.fromJson(jsonDecode(decryptTextFromBase64(
                String.fromCharCodes(
                    record.payload.sublist(record.payload[0] + 1)))));
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
          setState(() {
            isScanningNFC = false;
          });
        }
      },
    );
    setState(() {
      isScanningNFC = true;
    });
  }

  void _stopScanning() {
    NfcManager.instance.stopSession();
    setState(() {
      isScanningNFC = false;
    });
  }

  @override
  void dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    NfcManager.instance.stopSession();
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Photo, Full name, congregation
    return Scaffold(
      appBar: AppBar(title: const Text('Scan NFC')),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              if (isScanningNFC) {
                _stopScanning();
              } else {
                _startScanning();
              }
            },
            child: Text(isScanningNFC ? 'Scanning NFC' : 'Scan NFC'),
          ),
          Text('Name: ${dataNFC?.name}'),
          Text('Congregation: ${dataNFC?.congregation}'),
          TextButton(
              onPressed: () {
                if (isScanningQR) {
                  _stopScanningQR();
                } else {
                  _startScanningQR();
                }
              },
              child: Text(isScanningQR ? 'Scanning QR' : 'Scan QR')),
          if (isScanningQR)
            SizedBox(
                height: 250,
                width: 250,
                child: MobileScanner(controller: controller)),
          Text('Name: ${dataQR?.name}'),
          Text('Congregation: ${dataQR?.congregation}'),
          const Text('Image'),
        ],
      ),
    );
  }
}
