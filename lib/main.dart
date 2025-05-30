import 'package:flutter/material.dart';
import 'package:gym_app/custom_widgets.dart';
import 'package:gym_app/exercise_history.dart';
import 'package:gym_app/log_workout_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ypkpqorqsnsgeptjnlfh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlwa3Bxb3Jxc25zZ2VwdGpubGZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg0ODY5MTksImV4cCI6MjA2NDA2MjkxOX0.IYGpokFAZnpvlL1AVgJZMJGgqi2igePVseoHg_ntlAI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          floatingLabelStyle: TextStyle(
            backgroundColor: Colors.white,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

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
    return Scaffold(
      appBar: GymPalAppBar(),
      backgroundColor: Color(0xFF5C446E),
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
                backGroundColor: Colors.deepPurpleAccent,
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
