import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../model/member.dart';
import 'login_screen.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  DateTime? _dateSaved;
  DateTime? _dateBaptized;
  final _congregationNameController = TextEditingController();
  User? _user;
  late DatabaseReference _membersDB;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
    _membersDB = FirebaseDatabase.instance.ref("members");
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _congregationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MBBE Member registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Date Saved'),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dateSaved ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _dateSaved) {
                    setState(() {
                      _dateSaved = picked;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _dateSaved != null
                      ? '${_dateSaved!.day}/${_dateSaved!.month}/${_dateSaved!.year}'
                      : '',
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Date Baptized'),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dateBaptized ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _dateBaptized) {
                    setState(() {
                      _dateBaptized = picked;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _dateBaptized != null
                      ? '${_dateBaptized!.day}/${_dateBaptized!.month}/${_dateBaptized!.year}'
                      : '',
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _congregationNameController,
                decoration:
                    const InputDecoration(labelText: 'Congregation Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the congregation name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var error = "";
                    try {
                      final newMemberRef = _membersDB.push();
                      final newMemberData = Member(
                              name: _fullNameController.text,
                              dateSaved: _dateSaved!.millisecondsSinceEpoch,
                              dateBaptized:
                                  _dateBaptized!.millisecondsSinceEpoch,
                              congregation: _congregationNameController.text)
                          .toMap();
                      await newMemberRef.set(newMemberData);
                      error = "";
                    } catch (e) {
                      error = e.toString();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text(error.isNotEmpty ? error : "Success!")),
                      );
                    }
                  }
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => (_user != null)
                          ? const MyHomePage(title: 'Flutter Demo Home Page')
                          : const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
