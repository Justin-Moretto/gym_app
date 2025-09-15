import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_app/custom_widgets.dart';
import 'package:gym_app/pages/exercise_history_page.dart';
import 'package:gym_app/pages/log_workout_page.dart';
import 'package:gym_app/pages/exercise_library_page.dart';
import 'package:gym_app/pages/settings_page.dart';
import 'package:gym_app/styles/text_styles.dart';
import 'package:gym_app/helpers.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? daysSinceLastSession;

  @override
  void initState() {
    super.initState();
    _loadLastSession();
  }

  Future<void> _loadLastSession() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    try {
      // Get the most recent session (like exercise history page does)
      final response = await supabase
          .from('sessions')
          .select('timestamp')
          .order('timestamp', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final lastSessionTimestamp = response[0]['timestamp'] as String;
        final lastSessionDate = DateTime.parse(lastSessionTimestamp);
        final now = DateTime.now();
        
        // Calculate days difference
        final difference = now.difference(lastSessionDate).inDays;
        
        setState(() {
          daysSinceLastSession = difference;
        });
      } else {
        setState(() {
          daysSinceLastSession = null;
        });
      }
    } catch (e) {
      print('Error loading last session: $e');
      setState(() {
        daysSinceLastSession = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Tracker'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              MainPageButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExerciseHistoryPage(),
                    ),
                  );
                },
                labelText: "Workout History",
              ),
              MainPageButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExerciseLibraryPage(),
                    ),
                  );
                },
                labelText: "Exercise Library",
              ),
              MainPageButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExerciseHistoryPage(),
                    ),
                  );
                },
                labelText: "My Data & Trends",
              ),
              const Divider(height: 32, thickness: 1, indent: 40, endIndent: 40),
              buildDaysSinceLastSessionText(daysSinceLastSession),
              const Divider(height: 32, thickness: 1, indent: 40, endIndent: 40),
              MainPageButton(
                backGroundColor: theme.colorScheme.tertiary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LogWorkoutPage(),
                    ),
                  );
                },
                labelText: "Log New Workout",
              ),
            ],
          ),
        ),
      ),
    );
  }
} 