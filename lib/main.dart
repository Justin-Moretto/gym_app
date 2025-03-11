import 'package:flutter/material.dart';
import 'package:gym_app/classes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MuscleGroupModel chestAndArms;
  late MuscleGroupModel shouldersAndUpperBack;
  late MuscleGroupModel coreAndLowerBack;
  late MuscleGroupModel glutesAndLegs;

  List<MuscleGroupModel> muscleGroupCategoriesList = [];

  @override
  void initState() {
    super.initState();
    chestAndArms = MuscleGroupModel(
      name: "Chest & Arms",
      imagePath: "assets/chestImage.jpg",
    ); // Pecs, Biceps, Triceps
    shouldersAndUpperBack = MuscleGroupModel(
      name: "Shoulders & Upper Back",
      imagePath: "assets/backImage.jpg",
    ); // Delts, Lats, Traps
    coreAndLowerBack = MuscleGroupModel(
      name: "Core & Lower Back",
      imagePath: "assets/absImage.jpg",
    ); // Abs, Obliques, Erector Spinae
    glutesAndLegs = MuscleGroupModel(
      name: "Glutes & Legs",
      imagePath: "assets/legImage.jpg",
    ); // Glutes, Quads, Hamstrings, Calves

    muscleGroupCategoriesList.addAll([
      chestAndArms,
      shouldersAndUpperBack,
      coreAndLowerBack,
      glutesAndLegs,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(muscleGroupCategoriesList.length, (index) {
            return muscleGroupButton(
              muscleGroup: muscleGroupCategoriesList[index],
              context: context,
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget muscleGroupButton({
  required MuscleGroupModel muscleGroup,
  required BuildContext context,
}) {
  return Card(
    shape: RoundedRectangleBorder(
      side: const BorderSide(
        color: Color.fromARGB(255, 153, 114, 160),
        width: 3,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 9,
    child: InkWell(
      onTap: () => print("${muscleGroup.name} selected"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            muscleGroup.imagePath,
            width: 150,
            height: 150,
          ),
          Text(
            muscleGroup.name,
            style: TextTheme.of(context).headlineSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
