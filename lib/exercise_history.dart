import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'custom_widgets.dart';
import 'helpers.dart';

class ExerciseHistoryPage extends StatelessWidget {
  const ExerciseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GymPalAppBar(title: "Exercise History"),
      backgroundColor: theme.colorScheme.background,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('session_exercises')
            .select('*, sessions(timestamp), exercises(name)'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No exercise logs found.',
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            );
          }

          final logs = snapshot.data!;

          // ✅ Sort the logs by session timestamp in descending order
          logs.sort((a, b) {
            final t1 = DateTime.tryParse(a['sessions']['timestamp'] ?? '');
            final t2 = DateTime.tryParse(b['sessions']['timestamp'] ?? '');
            return t2!.compareTo(t1!);
          });

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final timestamp = log['sessions']['timestamp'];
              final exerciseName =
                  log['exercises']?['name'] ?? 'Unknown Exercise';

              return ListTile(
                title: Text(
                  exerciseName,
                  style: TextStyle(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${Helpers.formatWeight(log['weight'])} | ${Helpers.formatSetsAndReps(log['sets'], log['reps'])}\n${Helpers.formatTimestamp(timestamp)}',
                  style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
