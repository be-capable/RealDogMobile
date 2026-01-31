enum PetSex {
  male,
  female,
  unknown;

  String toJson() => name.toUpperCase();
  
  static PetSex fromJson(String json) {
    return PetSex.values.firstWhere(
      (e) => e.name.toUpperCase() == json,
      orElse: () => PetSex.unknown,
    );
  }
}

class Pet {
  final int id;
  final String name;
  final String species;
  final PetSex sex;
  final DateTime birthDate;
  final String breedId;
  final bool isSpayedNeutered;
  final int? avatarMediaId;

  Pet({
    required this.id,
    required this.name,
    this.species = 'DOG',
    required this.sex,
    required this.birthDate,
    required this.breedId,
    this.isSpayedNeutered = false,
    this.avatarMediaId,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      species: json['species'] ?? 'DOG',
      sex: PetSex.fromJson(json['sex']),
      birthDate: DateTime.parse(json['birthDate']),
      breedId: json['breedId'],
      isSpayedNeutered: json['isSpayedNeutered'] ?? false,
      avatarMediaId: json['avatarMediaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'sex': sex.toJson(),
      'birthDate': birthDate.toIso8601String(),
      'breedId': breedId,
      'isSpayedNeutered': isSpayedNeutered,
      'avatarMediaId': avatarMediaId,
    };
  }
}
