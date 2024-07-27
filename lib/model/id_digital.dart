class IdDigital {
  final String photo; // TODO link to Cloud store
  final String signature; // TODO link to Cloud store

  const IdDigital({
    required this.photo,
    required this.signature,
  });

  factory IdDigital.fromMap(Map<String, dynamic> element) {
    return IdDigital(
      photo: element['p'] as String,
      signature: element['s'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'p': photo,
        's': signature,
      };
}
