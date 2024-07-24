class IdDigital {
  final String name;
  final String congregation;
  final String image;

  //TODO firebase ID

  const IdDigital({
    required this.name,
    required this.congregation,
    required this.image,
  });

  factory IdDigital.fromJson(Map<String, dynamic> json) {
    return IdDigital(
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
