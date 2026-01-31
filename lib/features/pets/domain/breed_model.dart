class DogBreed {
  final String id;
  final String nameZh;
  final String nameEn;

  DogBreed({required this.id, required this.nameZh, required this.nameEn});

  String get displayName => nameZh.isNotEmpty ? nameZh : nameEn;

  factory DogBreed.fromJson(Map<String, dynamic> json) {
    return DogBreed(
      id: json['id'],
      nameZh: json['nameZh'] ?? '',
      nameEn: json['nameEn'] ?? '',
    );
  }
}

