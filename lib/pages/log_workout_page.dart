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
  List<ExerciseModel> allExercises = [];
  List<ExerciseModel> filteredExercises = [];
  Set<String> selectedExerciseIds = {};
  Map<String, List<Map<String, dynamic>>> setsPerExercise = {};
  Map<String, List<TextEditingController>> weightControllers = {};
  Map<String, List<TextEditingController>> repsControllers = {};

  @override
  void initState() {
    super.initState();
    fetchExercises();
    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredExercises = allExercises
            .where((exercise) => exercise.name.toLowerCase().contains(query))
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

  void toggleExercise(String id) {
    setState(() {
      if (selectedExerciseIds.contains(id)) {
        selectedExerciseIds.remove(id);
        setsPerExercise.remove(id);
        weightControllers.remove(id);
        repsControllers.remove(id);
      } else {
        selectedExerciseIds.add(id);
        setsPerExercise[id] = [
          {'weight': '', 'reps': ''}
        ];
        weightControllers[id] = [TextEditingController()];
        repsControllers[id] = [TextEditingController()];
      }
    });
  }

  void addSet(String id) {
    final sets = setsPerExercise[id]!;
    final weightControllersList = weightControllers[id]!;
    final repsControllersList = repsControllers[id]!;
    
    final lastWeightController = weightControllersList.last;
    final lastRepsController = repsControllersList.last;
    
    setState(() {
      setsPerExercise[id]!.add({
        'weight': lastWeightController.text,
        'reps': lastRepsController.text,
      });
      weightControllers[id]!.add(TextEditingController(text: lastWeightController.text));
      repsControllers[id]!.add(TextEditingController(text: lastRepsController.text));
    });
  }

  void removeSet(String id, int index) {
    setState(() {
      setsPerExercise[id]!.removeAt(index);
      weightControllers[id]![index].dispose();
      repsControllers[id]![index].dispose();
      weightControllers[id]!.removeAt(index);
      repsControllers[id]!.removeAt(index);
    });
  }

  Future<void> logWorkout() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final session = await supabase
          .from('sessions')
          .insert({
            'user_id': userId,
            'timestamp': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      final sessionId = session['id'];

      for (final id in selectedExerciseIds) {
        await supabase.from('session_exercises').insert({
          'session_id': sessionId,
          'exercise_id': id,
          'sets': setsPerExercise[id],
        });
      }

      setState(() {
        selectedExerciseIds.clear();
        setsPerExercise.clear();
        // Dispose all controllers
        for (final controllers in weightControllers.values) {
          for (final controller in controllers) {
            controller.dispose();
          }
        }
        for (final controllers in repsControllers.values) {
          for (final controller in controllers) {
            controller.dispose();
          }
        }
        weightControllers.clear();
        repsControllers.clear();
        searchController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = allExercises
        .where((e) => selectedExerciseIds.contains(e.id))
        .toList();

    return Scaffold(
      appBar: const GymPalAppBar(),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (selected.isEmpty) ...[
              TextField(
                controller: searchController,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final e = filteredExercises[index];
                    final selected = selectedExerciseIds.contains(e.id);
                    return ListTile(
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: selected ? Colors.white : theme.colorScheme.onBackground,
                          fontSize: 16,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: selected ? const Icon(Icons.check, color: Colors.green, size: 24) : null,
                      onTap: () => toggleExercise(e.id),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: selectedExerciseIds.isEmpty ? null : () => setState(() {}),
                child: const Text(
                  "Next: Log Sets",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ] else ...[
              Expanded(
                child: ListView(
                  children: selected.map((e) {
                    final sets = setsPerExercise[e.id]!;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (int i = 0; i < sets.length; i++)
                              Row(
                                children: [
                                  Text(
                                    "(${i + 1}) ",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: weightControllers[e.id]![i],
                                      decoration: const InputDecoration(
                                        labelText: 'Weight',
                                        labelStyle: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                                      ],
                                      onChanged: (val) => sets[i]['weight'] = val,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: repsControllers[e.id]![i],
                                      decoration: const InputDecoration(
                                        labelText: 'Reps',
                                        labelStyle: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      onChanged: (val) => sets[i]['reps'] = val,
                                    ),
                                  ),
                                ],
                              ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => addSet(e.id),
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  if (sets.length > 1)
                                    IconButton(
                                      onPressed: () => removeSet(e.id, sets.length - 1),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: logWorkout,
                child: const Text(
                  "Log Workout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  selectedExerciseIds.clear();
                  setsPerExercise.clear();
                  // Dispose all controllers
                  for (final controllers in weightControllers.values) {
                    for (final controller in controllers) {
                      controller.dispose();
                    }
                  }
                  for (final controllers in repsControllers.values) {
                    for (final controller in controllers) {
                      controller.dispose();
                    }
                  }
                  weightControllers.clear();
                  repsControllers.clear();
                }),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
