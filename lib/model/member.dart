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

  factory Member.fromMap(Map<String, dynamic> element) {
    return Member(
      name: element['n'] as String,
      dateSaved: element['ds'] as int,
      dateBaptized: element['db'] as int,
      congregation: element['c'] as String,
      attributes: element['a'] as String,
      digitalId: IdDigital.fromMap(element['digitalId']),
      firebaseUserId: element['fu'] as String,
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
