import 'package:flutter/material.dart';
import 'package:gym_app/custom_widgets.dart' show GymPalAppBar;
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseHistoryPage extends StatelessWidget {
  const ExerciseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: GymPalAppBar(
        //title: const Text("Exercise History"),
      ),
      backgroundColor: const Color(0xFF5C446E),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('exercise_logs')
            .stream(primaryKey: ['id'])
            .order('timestamp', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No exercise logs found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final logs = snapshot.data!;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text(
                  log['exercise_name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${log['weight']} lbs | ${log['sets']} sets x ${log['reps']} reps\n${log['timestamp']}',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
