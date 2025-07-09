import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_app/custom_widgets.dart';
import 'package:gym_app/data_models.dart';
import 'package:gym_app/styles/text_styles.dart';
import 'package:gym_app/pages/exercise_detail_page.dart';

class ExerciseLibraryPage extends StatefulWidget {
  const ExerciseLibraryPage({super.key});

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  final TextEditingController searchController = TextEditingController();
  List<ExerciseModel> allExercises = [];
  List<ExerciseModel> filteredExercises = [];

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymPalAppBar(title: "Exercise Library"),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        e.name,
                        style: AppTextStyles.withColor(AppTextStyles.listItem, theme.colorScheme.onBackground),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseDetailPage(exercise: e),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 