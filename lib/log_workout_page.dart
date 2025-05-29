import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/custom_widgets.dart';
import 'package:gym_app/data_models.dart';

class LogWorkoutPage extends StatefulWidget {
  const LogWorkoutPage({super.key});

  @override
  State<LogWorkoutPage> createState() => _LogWorkoutPageState();
}

class _LogWorkoutPageState extends State<LogWorkoutPage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();

  String? selectedExerciseName;

  late final List<ExerciseModel> placeholderData;
  List<ExerciseModel> filteredExercises = [];

  @override
  void initState() {
    super.initState();
    placeholderData = [
      ExerciseModel(
        name: "Bench",
        musclesTargeted: [
          MuscleModel(name: "Pectorals", muscleGroup: "upper body"),
          MuscleModel(name: "Triceps", muscleGroup: "upper body"),
        ],
      ),
      ExerciseModel(
        name: "Squat",
        musclesTargeted: [
          MuscleModel(name: "Quads", muscleGroup: "lower body"),
          MuscleModel(name: "Glutes", muscleGroup: "lower body"),
        ],
      ),
      ExerciseModel(
        name: "Dumbbell curl",
        musclesTargeted: [
          MuscleModel(name: "Biceps", muscleGroup: "upper body"),
        ],
      ),
      ExerciseModel(
        name: "Decline Sit-ups",
        musclesTargeted: [MuscleModel(name: "Abs", muscleGroup: "Core")],
      ),
    ];
    filteredExercises = List.from(placeholderData);

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredExercises =
            placeholderData
                .where(
                  (exercise) => exercise.name.toLowerCase().contains(query),
                )
                .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (selectedExerciseName == null) {
      content = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search exercises:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 7),
            TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Type to search',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.zero,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.zero,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: const Border(
                        top: BorderSide(color: Colors.white, width: 1),
                        bottom: BorderSide(color: Colors.white, width: 1),
                        left: BorderSide(color: Colors.white, width: 2),
                        right: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        exercise.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        setState(() {
                          selectedExerciseName = exercise.name;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      content = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Logging: $selectedExerciseName",
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Weight (lbs)', style: TextStyle(color: Colors.white)),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: 'Enter weight'),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text('Sets', style: TextStyle(color: Colors.white)),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: 'Enter sets'),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text('Reps', style: TextStyle(color: Colors.white)),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: 'Enter reps'),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print(
                  "Logged: $selectedExerciseName - ${weightController.text} lbs, ${setsController.text} sets, ${repsController.text} reps",
                );
              },
              child: const Text("Log Workout"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedExerciseName = null;
                  searchController.clear();
                });
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF5C446E),
      appBar: const GymPalAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [content],
        ),
      ),
    );
  }
}
