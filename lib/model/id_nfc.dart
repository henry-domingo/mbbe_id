class IdNfc {
  final String name;
  final String congregation;
  final String image;

  //TODO firebase ID

  const IdNfc({
    required this.name,
    required this.congregation,
    required this.image,
  });

  factory IdNfc.fromJson(Map<String, dynamic> json) {
    return IdNfc(
      name: json['n'] as String,
      congregation: json['c'] as String,
      image: json['i'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'n': name,
        'c': congregation,
        'i': image,
      };
}
