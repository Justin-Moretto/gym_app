import 'package:flutter/material.dart';
import 'package:gym_app/custom_widgets.dart';
import 'package:gym_app/pages/exercise_history_page.dart';
import 'package:gym_app/pages/log_workout_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
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
            onPressed: () async {
              // Log out the user
              final supabase = Supabase.instance.client;
              await supabase.auth.signOut();

              // Navigate to login page and clear the stack
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
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
                      builder: (context) => const LogWorkoutPage(),
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
