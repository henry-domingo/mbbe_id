import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mbbe_id/model/id_nfc.dart';
import 'package:mime/mime.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../helpers.dart';
import 'capture_image_screen.dart';

class WriteNfcScreen extends StatefulWidget {
  const WriteNfcScreen({super.key});

  @override
  State<WriteNfcScreen> createState() => _WriteNfcScreenState();
}

class _WriteNfcScreenState extends State<WriteNfcScreen> {
  var isAvailable = false;
  var isWriting = false;
  var stringData = '';
  var mimeImage = '';

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final congregationController = TextEditingController();

  Uint8List? _imgCapturedBytes;

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
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        if (!isWriting) return;

        Ndef? ndef = Ndef.from(tag);
        if (ndef != null && ndef.isWritable) {
          try {
            await ndef.write(NdefMessage(
                [NdefRecord.createText(encryptTextToBase64(stringData))]));
          } catch (e) {
            NfcManager.instance.stopSession(errorMessage: e.toString());
          }

          setState(() {
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
            if (_imgCapturedBytes != null)
              Image(image: Image.memory(_imgCapturedBytes!).image),
            TextButton(
                onPressed: () async {
                  final cameras = await availableCameras();
                  if (context.mounted) {
                    //XFile
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CaptureImageScreen(
                                camera: cameras.first,
                              )),
                    );
                    if (result != null && result is XFile) {
                      final bytes = await result.readAsBytes();
                      mimeImage = lookupMimeType(result.path) ?? 'image/jpeg';
                      setState(() {
                        _imgCapturedBytes = bytes;
                      });
                    }
                  }
                },
                child: const Text('Take picture')),
            TextButton(
                onPressed: () {
                  if (isWriting) {
                    NfcManager.instance.stopSession();
                    setState(() {
                      isWriting = false;
                    });
                  } else {
                    if (_imgCapturedBytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo is required!')));
                    } else {
                      if (_formKey.currentState!.validate()) {
                        stringData = jsonEncode(IdNfc(
                                name: nameController.text,
                                congregation: congregationController.text)
                            .toJson());
                        setState(() {
                          isWriting = true;
                        });
                        _writeTag();
                      }
                    }
                  }
                },
                child: Text(isWriting ? 'Cancel writing' : 'Write to NFC')),
          ],
        ),
      ),
    );
  }
}
