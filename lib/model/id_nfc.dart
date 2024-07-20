class IdNfc {
  final String name;
  final String congregation;

  //TODO firebase ID

  const IdNfc({
    required this.name,
    required this.congregation,
  });

  factory IdNfc.fromJson(Map<String, dynamic> json) {
    return IdNfc(
      name: json['n'] as String,
      congregation: json['c'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'n': name,
        'c': congregation,
      };
}
