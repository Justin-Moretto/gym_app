import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/custom_widgets.dart';
import 'package:gym_app/old_main.dart';

class LogWorkoutPage extends StatefulWidget {
  const LogWorkoutPage({super.key});

  @override
  State<LogWorkoutPage> createState() => _LogWorkoutPageState();
}

class _LogWorkoutPageState extends State<LogWorkoutPage> {
  final TextEditingController exerciseController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GymPalAppBar(),
      body: Row(
        children: [
          // Exercise Text Field
          Expanded(
            child: TextField(
              controller: exerciseController,
              decoration: InputDecoration(
                labelText: 'Exercise',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 8),

          // Weight Text Field (Only numbers)
          Expanded(
            child: TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Weight (lbs)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 8),

          // Sets Text Field (Only numbers)
          Expanded(
            child: TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Sets',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 8),

          // Reps Text Field (Only numbers)
          Expanded(
            child: TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
