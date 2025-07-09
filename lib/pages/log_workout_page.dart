import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/custom_widgets.dart';
import 'package:gym_app/data_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_app/styles/text_styles.dart';

enum WorkoutPhase {
  exerciseSelection,
  loggingSets,
  // selectDate, // Future phase
}

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
  WorkoutPhase currentPhase = WorkoutPhase.exerciseSelection;

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
    
    // Check if we've reached the maximum of 10 sets
    if (sets.length >= 10) return;
    
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
        currentPhase = WorkoutPhase.exerciseSelection;
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
            if (currentPhase == WorkoutPhase.exerciseSelection) ...[
              TextField(
                controller: searchController,
                style: AppTextStyles.withColor(AppTextStyles.inputField, theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: AppTextStyles.withOpacity(AppTextStyles.inputHint, theme.colorScheme.onSurface, 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final e = filteredExercises[index];
                    final selected = selectedExerciseIds.contains(e.id);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: selected ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: selected 
                          ? BorderSide(color: Colors.white.withOpacity(0.3), width: 1)
                          : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Icon(
                          selected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: selected ? Colors.green : Colors.grey,
                          size: 24,
                        ),
                        title: Text(
                          e.name,
                          style: AppTextStyles.withColor(
                            selected ? AppTextStyles.listItemSelected : AppTextStyles.listItem,
                            selected ? Colors.white : theme.colorScheme.onBackground,
                          ),
                        ),
                        onTap: () => toggleExercise(e.id),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: selectedExerciseIds.isEmpty ? null : () => setState(() {
                  currentPhase = WorkoutPhase.loggingSets;
                }),
                child: const Text(
                  "Next: Log Sets",
                  style: AppTextStyles.buttonSmall,
                ),
              ),
            ] else if (currentPhase == WorkoutPhase.loggingSets) ...[
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
                              style: AppTextStyles.withColor(AppTextStyles.cardTitle, Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: List.generate(sets.length, (i) => Padding(
                                padding: EdgeInsets.only(bottom: i < sets.length - 1 ? 12.0 : 0),
                                child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${i + 1}",
                                        style: AppTextStyles.withColor(AppTextStyles.cardSubtitle, Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: weightControllers[e.id]![i],
                                      decoration: InputDecoration(
                                        labelText: 'Weight',
                                        labelStyle: AppTextStyles.withColor(AppTextStyles.inputLabel, Colors.white70),
                                      ),
                                      style: AppTextStyles.withColor(AppTextStyles.inputField, Colors.white),
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
                                      decoration: InputDecoration(
                                        labelText: 'Reps',
                                        labelStyle: AppTextStyles.withColor(AppTextStyles.inputLabel, Colors.white70),
                                      ),
                                      style: AppTextStyles.withColor(AppTextStyles.inputField, Colors.white),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      onChanged: (val) => sets[i]['reps'] = val,
                                    ),
                                  ),
                                ],
                              )),
                            ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  if (sets.length < 10)
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
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => toggleExercise(e.id),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 24,
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
                  style: AppTextStyles.buttonSmall,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  selectedExerciseIds.clear();
                  setsPerExercise.clear();
                  currentPhase = WorkoutPhase.exerciseSelection;
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
                child: Text(
                  "Cancel",
                  style: AppTextStyles.withColor(AppTextStyles.buttonSecondary, Colors.white),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
