import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../helpers.dart';

class ScanNfcScreen extends StatefulWidget {
  const ScanNfcScreen({super.key});

  @override
  State<ScanNfcScreen> createState() => _ScanNfcScreenState();
}

class _ScanNfcScreenState extends State<ScanNfcScreen> {
  var isAvailable = false;
  var isScanning = false;
  var text = '';

  @override
  void initState() {
    super.initState();
    _checkNFC();
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
            isScanning = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Tag is not NDEF.')));
          return;
        }
        if (!ndef.isWritable) {
          setState(() {
            isScanning = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tag is not writable.')));
          return;
        }
        try {
          final data = await ndef.read();
          final record = data.records.firstOrNull;
          if (record == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('No records.')));
            }
            setState(() {
              isScanning = false;
            });
            return;
          }
          setState(() {
            isScanning = false;
            text = decryptTextFromBase64(String.fromCharCodes(
                record.payload.sublist(record.payload[0] + 1)));
          });
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
          setState(() {
            isScanning = false;
          });
        }
      },
    );
    setState(() {
      isScanning = true;
    });
  }

  void _stopScanning() {
    NfcManager.instance.stopSession();
    setState(() {
      isScanning = false;
    });
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
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
              if (isScanning) {
                _stopScanning();
              } else {
                _startScanning();
              }
            },
            child: Text(isScanning ? 'Stop' : 'Scan'),
          ),
          Text('data: $text'),
        ],
      ),
    );
  }
}
