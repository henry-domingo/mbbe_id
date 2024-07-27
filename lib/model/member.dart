import 'package:firebase_database/firebase_database.dart';

import 'id_digital.dart';

class Member {
  final String name;
  final int dateSaved;
  final int dateBaptized;
  final String congregation;
  final String?
      attributes; // inactive, invalid digital ID, validated, issued, etc.
  final IdDigital? digitalId;
  final String? firebaseUserId;

  const Member({
    required this.name,
    required this.dateSaved,
    required this.dateBaptized,
    required this.congregation,
    this.attributes,
    this.digitalId,
    this.firebaseUserId,
  });

  factory Member.fromSnapshot(DataSnapshot snapshot) {
    final snapshotID = snapshot.child('digitalId');
    return Member(
      name: snapshot.child('n').value as String,
      dateSaved: snapshot.child('ds').value as int,
      dateBaptized: snapshot.child('db').value as int,
      congregation: snapshot.child('c').value as String,
      attributes: snapshot.child('a').value as String?,
      digitalId:
          snapshotID.value != null ? IdDigital.fromSnapshot(snapshotID) : null,
      firebaseUserId: snapshot.child('fu').value as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'n': name,
        'ds': dateSaved,
        'db': dateBaptized,
        'c': congregation,
        'a': attributes,
        'digitalId': digitalId,
        'fu': firebaseUserId,
      };
}
