import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_app/custom_widgets.dart';
import 'package:gym_app/data_models.dart';
import 'package:gym_app/styles/text_styles.dart';
import 'package:gym_app/helpers.dart';

class ExerciseDetailPage extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  List<String> targetedMuscles = [];
  Map<String, dynamic>? personalRecord;
  List<Map<String, dynamic>> exerciseHistory = [];

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
  }

  Future<void> _loadExerciseData() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    try {
      // Load targeted muscles
      final musclesResponse = await supabase
          .from('exercise_muscles')
          .select('muscles(name), exercise_id')
          .eq('exercise_id', widget.exercise.id);

      print('Raw muscles response: $musclesResponse');

      if (mounted && musclesResponse.isNotEmpty) {
        setState(() {
          targetedMuscles =
              (musclesResponse as List)
                  .map((e) => e['muscles']?['name'] as String?)
                  .whereType<String>()
                  .toList();
        });
      }

      // Load personal record (highest weight)
      final prResponse = await supabase
          .from('session_exercises')
          .select('sets, sessions!session_id(user_id)')
          .eq('exercise_id', widget.exercise.id)
          .eq('sessions.user_id', userId);

      if (prResponse.isNotEmpty) {
        double maxWeight = 0;
        int maxReps = 0;

        for (final session in prResponse) {
          final sets = session['sets'] as List;
          for (final set in sets) {
            final weight =
                double.tryParse(set['weight']?.toString() ?? '0') ?? 0;
            final reps = int.tryParse(set['reps']?.toString() ?? '0') ?? 0;

            if (weight > maxWeight) {
              maxWeight = weight;
              maxReps = reps;
            }
          }
        }

        if (maxWeight > 0) {
          setState(() {
            personalRecord = {'weight': maxWeight, 'reps': maxReps};
          });
        }
      }

      // Load exercise history
      final historyResponse = await supabase
          .from('session_exercises')
          .select('*, sessions!session_id(timestamp)')
          .eq('exercise_id', widget.exercise.id)
          .eq('sessions.user_id', userId)
          .limit(20);

      // Sort by timestamp on client side
      final sortedHistory =
          (historyResponse as List).cast<Map<String, dynamic>>();
      sortedHistory.sort((a, b) {
        final timestampA = a['sessions']?['timestamp'] as String?;
        final timestampB = b['sessions']?['timestamp'] as String?;

        if (timestampA == null && timestampB == null) return 0;
        if (timestampA == null) return 1;
        if (timestampB == null) return -1;

        return timestampB.compareTo(timestampA); // Most recent first
      });

      setState(() {
        exerciseHistory = sortedHistory;
      });
    } catch (e) {
      print('Error loading exercise data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymPalAppBar(),
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Name
            Text(
              widget.exercise.name,
              style: AppTextStyles.withColor(
                AppTextStyles.appTitle,
                theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 24),

            // Targeted Muscles
            if (targetedMuscles.isNotEmpty) ...[
              Text(
                'Targeted Muscles',
                style: AppTextStyles.withColor(
                  AppTextStyles.cardTitle,
                  theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    targetedMuscles
                        .map(
                          (muscle) => Chip(
                            label: Text(muscle),
                            backgroundColor: theme.colorScheme.secondary,
                            labelStyle: AppTextStyles.withColor(
                              AppTextStyles.cardSubtitle,
                              theme.colorScheme.onSecondary,
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Personal Record
            if (personalRecord != null) ...[
              Text(
                'Personal Record',
                style: AppTextStyles.withColor(
                  AppTextStyles.cardTitle,
                  theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${personalRecord!['weight']} lbs',
                            style: AppTextStyles.withColor(
                              AppTextStyles.cardTitleLarge,
                              theme.colorScheme.onBackground,
                            ),
                          ),
                          Text(
                            '${personalRecord!['reps']} reps',
                            style: AppTextStyles.withColor(
                              AppTextStyles.cardSubtitle,
                              theme.colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Exercise History
            Text(
              'Recent History',
              style: AppTextStyles.withColor(
                AppTextStyles.cardTitle,
                theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            if (exerciseHistory.isNotEmpty) ...[
              ...exerciseHistory.map((session) {
                final timestamp = session['sessions']?['timestamp'];
                final sets = session['sets'] as List;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Helpers.formatTimestamp(timestamp),
                              style: AppTextStyles.withColor(
                                AppTextStyles.cardSubtitle,
                                theme.colorScheme.onBackground,
                              ),
                            ),
                            Text(
                              '${sets.length} sets',
                              style: AppTextStyles.withColor(
                                AppTextStyles.cardSubtitle,
                                theme.colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...sets.asMap().entries.map((entry) {
                          final i = entry.key + 1;
                          final set = entry.value;
                          final weight = set['weight'];
                          final reps = set['reps'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Set $i: $weight lbs × $reps reps',
                              style: AppTextStyles.withColor(
                                AppTextStyles.listItem,
                                theme.colorScheme.onBackground,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No history found for this exercise.',
                    style: AppTextStyles.withColor(
                      AppTextStyles.listItem,
                      theme.colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
