import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/custom_widgets.dart';
import 'package:gym_app/data_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  List<ExerciseModel> allExercises = [];
  List<ExerciseModel> filteredExercises = [];
  ExerciseModel? selectedExercise;

  @override
  void initState() {
    super.initState();
    fetchExercises();
    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredExercises =
            allExercises
                .where(
                  (exercise) => (exercise.name).toLowerCase().contains(query),
                )
                .toList();
      });
    });
  }

  Future<void> fetchExercises() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('exercises').select();
    setState(() {
      allExercises =
          (response as List).map((e) => ExerciseModel.fromJson(e)).toList();
      filteredExercises = allExercises;
    });
  }

  Future<void> logWorkout() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    print("Current user ID: $userId"); //debug

    if (userId == null) {
      print("User not signed in.");
      return;
    }
    print(
      "Access token: ${Supabase.instance.client.auth.currentSession?.accessToken}",
    );

    // Single insert and retrieve new session with user_id
    final sessionResponse =
        await supabase
            .from('sessions')
            .insert({
              'user_id': userId,
              'timestamp': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    final sessionId = sessionResponse['id'];

    final response = await supabase.from('session_exercises').insert({
      'session_id': sessionId,
      'exercise_id': selectedExercise!.id,
      'weight': int.tryParse(weightController.text) ?? 0,
      'sets': int.tryParse(setsController.text) ?? 0,
      'reps': int.tryParse(repsController.text) ?? 0,
    });

    print("Insert response: $response");

    setState(() {
      selectedExercise = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (selectedExercise == null) {
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
                          selectedExercise = exercise;
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
              "Logging: ${selectedExercise!.name}",
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
              onPressed: logWorkout,
              child: const Text("Log Workout"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedExercise = null;
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
