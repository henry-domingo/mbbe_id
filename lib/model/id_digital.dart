import 'package:firebase_database/firebase_database.dart';

class IdDigital {
  final String photo; // TODO link to Cloud store
  final String signature; // TODO link to Cloud store

  const IdDigital({
    required this.photo,
    required this.signature,
  });

  factory IdDigital.fromSnapshot(DataSnapshot snapshot) {
    return IdDigital(
      photo: snapshot.child('p').value as String,
      signature: snapshot.child('s').value as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'p': photo,
        's': signature,
      };
}
