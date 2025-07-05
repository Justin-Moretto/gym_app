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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not signed in. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate input fields
    if (weightController.text.isEmpty || setsController.text.isEmpty || repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields (weight, sets, and reps)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
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

      await supabase.from('session_exercises').insert({
        'session_id': sessionId,
        'exercise_id': selectedExercise!.id,
        'weight': int.tryParse(weightController.text) ?? 0,
        'sets': int.tryParse(setsController.text) ?? 0,
        'reps': int.tryParse(repsController.text) ?? 0,
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully logged ${selectedExercise!.name} workout!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Clear form and reset state
      setState(() {
        selectedExercise = null;
        weightController.clear();
        setsController.clear();
        repsController.clear();
      });

    } catch (error) {
      print("Error logging workout: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log workout: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget content;

    if (selectedExercise == null) {
      content = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search exercises:',
              style: TextStyle(color: theme.colorScheme.onBackground),
            ),
            const SizedBox(height: 7),
            TextField(
              controller: searchController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Type to search',
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.zero,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.zero,
                ),
                focusedBorder: const OutlineInputBorder(
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
                      border: Border(
                        top: BorderSide(color: theme.colorScheme.onBackground, width: 1),
                        bottom: BorderSide(color: theme.colorScheme.onBackground, width: 1),
                        left: BorderSide(color: theme.colorScheme.onBackground, width: 2),
                        right: BorderSide(color: theme.colorScheme.onBackground, width: 2),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        exercise.name,
                        style: TextStyle(color: theme.colorScheme.onBackground),
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
              style: TextStyle(fontSize: 18, color: theme.colorScheme.onBackground),
            ),
            const SizedBox(height: 16),
            Text('Weight (lbs)', style: TextStyle(color: theme.colorScheme.onBackground)),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter weight',
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Sets', style: TextStyle(color: theme.colorScheme.onBackground)),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter sets',
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Reps', style: TextStyle(color: theme.colorScheme.onBackground)),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter reps',
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
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
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
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
