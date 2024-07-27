import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../model/member.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  late final DatabaseReference _databaseReference;
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref('members');
    _getMembers();
  }

  void _getMembers() {
    _databaseReference.onValue.listen((event) {
      setState(() {
        _members = [];
        for (final child in event.snapshot.children) {
          _members.add(Member.fromSnapshot(child));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member List'),
      ),
      body: ListView.builder(
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return ListTile(
            title: Text(member.name),
            subtitle: Text(member.congregation),
          );
        },
      ),
    );
  }
}
