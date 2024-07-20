import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mbbe_id/model/id_nfc.dart';
import 'package:mime/mime.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../helpers.dart';
import 'capture_image_screen.dart';

class WriteCardScreen extends StatefulWidget {
  const WriteCardScreen({super.key});

  @override
  State<WriteCardScreen> createState() => _WriteCardScreenState();
}

class _WriteCardScreenState extends State<WriteCardScreen> {
  var isAvailable = false;
  var isWriting = false;
  var stringDataNFC = '';
  var stringDataQR = '';
  var mimeImage = '';

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final congregationController = TextEditingController();

  var _qrData = '';

  @override
  void initState() {
    super.initState();
    _checkNFC();
  }

  Future<void> _checkNFC() async {
    isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {}
  }

  void _writeTag() {
    final dataToBeWritten = encryptTextToBase64(stringDataNFC);
    setState(() {
      _qrData = encryptTextToBase64(stringDataQR);
    });
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        if (!isWriting) return;

        Ndef? ndef = Ndef.from(tag);
        if (ndef != null && ndef.isWritable) {
          try {
            await ndef
                .write(NdefMessage([NdefRecord.createText(dataToBeWritten)]));
          } catch (e) {
            NfcManager.instance.stopSession(errorMessage: e.toString());
          }

          setState(() {
            nameController.text = '';
            congregationController.text = '';
            isWriting = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    congregationController.dispose();
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write NFC')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full Name'),
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Congregation'),
              controller: congregationController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Congregation is required';
                }
                return null;
              },
            ),
            TextButton(
                onPressed: () {
                  if (isWriting) {
                    NfcManager.instance.stopSession();
                    setState(() {
                      isWriting = false;
                    });
                  } else {
                    if (_formKey.currentState!.validate()) {
                      stringDataNFC = jsonEncode(IdNfc(
                              name: nameController.text,
                              congregation: congregationController.text,
                              image: '')
                          .toJson());
                      stringDataQR = stringDataNFC;
                      setState(() {
                        isWriting = true;
                        _qrData = '';
                      });
                      _writeTag();
                    }
                  }
                },
                child: Text(isWriting
                    ? 'Cancel writing'
                    : 'Write to NFC & Generate QR')),
            const Text('QR'),
            if (_qrData.isNotEmpty)
              QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
          ],
        ),
      ),
    );
  }
}
