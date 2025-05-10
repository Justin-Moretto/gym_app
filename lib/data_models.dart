
class ExerciseModel {
  final String name;
  int weight;
  int reps;
  int sets;
  // List<MuscleModel> musclesTargeted = [],
  DateTime? timeLastLogged;

  ExerciseModel({
    required this.name,
    this.weight = 0,
    this.reps = 0,
    this.sets = 0,
    List<MuscleModel> musclesTargeted = const [],
    DateTime? timeLastLogged,
  });
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
