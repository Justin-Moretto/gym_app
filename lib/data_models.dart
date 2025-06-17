class ExerciseModel {
  final String id;
  final String name;
  int weight;
  int reps;
  int sets;
  List<MuscleModel> musclesTargeted;
  DateTime? timeLastLogged;

  ExerciseModel({
    required this.id,
    required this.name,
    this.weight = 0,
    this.reps = 0,
    this.sets = 0,
    this.musclesTargeted = const [],
    this.timeLastLogged,
  });

  // Factory constructor to create ExerciseModel from JSON (Map)
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      weight: json['weight'] ?? 0,
      reps: json['reps'] ?? 0,
      sets: json['sets'] ?? 0,
      musclesTargeted: [], // We can extend this later if muscles are joined
      timeLastLogged:
          json['timeLastLogged'] != null
              ? DateTime.tryParse(json['timeLastLogged'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'timeLastLogged': timeLastLogged?.toIso8601String(),
      // 'musclesTargeted': musclesTargeted.map((m) => m.toJson()).toList(), // optional
    };
  }
}

class MuscleGroupModel {
  final String name;
  String imagePath;

  MuscleGroupModel({
    required this.name,
    // required List<MuscleModel> muscles,
    this.imagePath = "assets/absImage.jpg",
  });
}

class MuscleModel {
  MuscleModel({required String name, required String muscleGroup});
}

// Chest & Arms - Pecs, Biceps, Triceps
// Shoulders & Upper Back - Delts, Lats, Traps
// Core & Lower Back - Abs, Glutes, Obliques
// Legs - Quads, Hamstrings, Calves

// Compound Lifts: Squat, bench, Pull-up
