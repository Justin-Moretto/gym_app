import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../custom_widgets.dart';
import '../helpers.dart';

class ExerciseHistoryPage extends StatefulWidget {
  const ExerciseHistoryPage({super.key});

  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  DateTime? selectedDate;
  List<DateTime> availableDates = [];
  int currentDateIndex = 0;
  bool showRecentLifts = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableDates();
  }

  Future<void> _loadAvailableDates() async {
    final supabase = Supabase.instance.client;
    try {
      // Get all sessions with timestamps
      final sessionsResponse = await supabase
          .from('sessions')
          .select('id, timestamp')
          .order('timestamp', ascending: false);
      
      final dates = <DateTime>{};
      for (final session in sessionsResponse as List) {
        final timestamp = session['timestamp'];
        if (timestamp != null) {
          final date = DateTime.parse(timestamp);
          dates.add(DateTime(date.year, date.month, date.day));
        }
      }
      
      final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));
      
      setState(() {
        availableDates = sortedDates;
        if (sortedDates.isNotEmpty) {
          selectedDate = sortedDates[0];
          currentDateIndex = 0;
        }
      });
    } catch (e) {
      print('Error loading dates: $e');
    }
  }

  void _previousDate() {
    if (currentDateIndex < availableDates.length - 1) {
      setState(() {
        currentDateIndex++;
        selectedDate = availableDates[currentDateIndex];
      });
    }
  }

  void _nextDate() {
    if (currentDateIndex > 0) {
      setState(() {
        currentDateIndex--;
        selectedDate = availableDates[currentDateIndex];
      });
    }
  }

  void _toggleRecentLifts() {
    setState(() {
      showRecentLifts = !showRecentLifts;
    });
  }

  Future<List<Map<String, dynamic>>> _getSessionExercisesForDate(
    SupabaseClient supabase, 
    DateTime startOfDay, 
    DateTime endOfDay
  ) async {
    try {
      // First, get sessions for the date range
      final sessionsResponse = await supabase
          .from('sessions')
          .select('id, timestamp')
          .gte('timestamp', startOfDay.toIso8601String())
          .lt('timestamp', endOfDay.toIso8601String())
          .order('timestamp', ascending: false);
      
      if (sessionsResponse.isEmpty) {
        return [];
      }
      
      final sessionIds = (sessionsResponse as List).map((s) => s['id']).toList();
      
      // Then get session exercises for those sessions
      final exercisesResponse = await supabase
          .from('session_exercises')
          .select('*, exercises(name)')
          .inFilter('session_id', sessionIds);
      
      // Create a map of session_id to timestamp for easy lookup
      final sessionTimestamps = <String, String>{};
      for (final session in sessionsResponse) {
        sessionTimestamps[session['id']] = session['timestamp'];
      }
      
      // Join the data in Dart
      final result = <Map<String, dynamic>>[];
      for (final exercise in exercisesResponse as List) {
        final sessionId = exercise['session_id'];
        final timestamp = sessionTimestamps[sessionId];
        
        result.add({
          ...exercise,
          'sessions': {'timestamp': timestamp},
        });
      }
      
      // Sort by timestamp (most recent first)
      result.sort((a, b) {
        final t1 = DateTime.tryParse(a['sessions']?['timestamp'] ?? '');
        final t2 = DateTime.tryParse(b['sessions']?['timestamp'] ?? '');
        if (t1 == null && t2 == null) return 0;
        if (t1 == null) return 1;
        if (t2 == null) return -1;
        return t2.compareTo(t1);
      });
      
      return result;
    } catch (e) {
      print('Error getting session exercises: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentSessionExercises(
    SupabaseClient supabase
  ) async {
    try {
      // First, get recent sessions
      final sessionsResponse = await supabase
          .from('sessions')
          .select('id, timestamp')
          .order('timestamp', ascending: false)
          .limit(20);
      
      if (sessionsResponse.isEmpty) {
        return [];
      }
      
      final sessionIds = (sessionsResponse as List).map((s) => s['id']).toList();
      
      // Then get session exercises for those sessions
      final exercisesResponse = await supabase
          .from('session_exercises')
          .select('*, exercises(name)')
          .inFilter('session_id', sessionIds);
      
      // Create a map of session_id to timestamp for easy lookup
      final sessionTimestamps = <String, String>{};
      for (final session in sessionsResponse) {
        sessionTimestamps[session['id']] = session['timestamp'];
      }
      
      // Join the data in Dart
      final result = <Map<String, dynamic>>[];
      for (final exercise in exercisesResponse as List) {
        final sessionId = exercise['session_id'];
        final timestamp = sessionTimestamps[sessionId];
        
        result.add({
          ...exercise,
          'sessions': {'timestamp': timestamp},
        });
      }
      
      // Sort by timestamp (most recent first)
      result.sort((a, b) {
        final t1 = DateTime.tryParse(a['sessions']?['timestamp'] ?? '');
        final t2 = DateTime.tryParse(b['sessions']?['timestamp'] ?? '');
        if (t1 == null && t2 == null) return 0;
        if (t1 == null) return 1;
        if (t2 == null) return -1;
        return t2.compareTo(t1);
      });
      
      return result;
    } catch (e) {
      print('Error getting recent session exercises: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GymPalAppBar(title: "Exercise History"),
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Date Selector
          if (availableDates.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: currentDateIndex < availableDates.length - 1 
                        ? _previousDate 
                        : null,
                    icon: Icon(
                      Icons.chevron_left,
                      color: currentDateIndex < availableDates.length - 1 
                          ? theme.colorScheme.onBackground 
                          : theme.colorScheme.onBackground.withOpacity(0.3),
                      size: 28,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Show calendar picker
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        selectedDate != null 
                            ? Helpers.formatDate(selectedDate!)
                            : 'Select Date',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: currentDateIndex > 0 ? _nextDate : null,
                    icon: Icon(
                      Icons.chevron_right,
                      color: currentDateIndex > 0 
                          ? theme.colorScheme.onBackground 
                          : theme.colorScheme.onBackground.withOpacity(0.3),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            // Recent Lifts Toggle Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleRecentLifts,
                      icon: Icon(
                        showRecentLifts ? Icons.list : Icons.history,
                        color: theme.colorScheme.onSecondary,
                      ),
                      label: Text(
                        showRecentLifts ? 'Show by Date' : 'Show Recent Lifts',
                        style: TextStyle(
                          color: theme.colorScheme.onSecondary,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Content
          Expanded(
            child: showRecentLifts 
                ? _buildRecentLiftsView(supabase, theme)
                : _buildDateSpecificView(supabase, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSpecificView(SupabaseClient supabase, ThemeData theme) {
    if (selectedDate == null) {
      return const Center(child: Text('No date selected'));
    }

    final startOfDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getSessionExercisesForDate(supabase, startOfDay, endOfDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No exercises logged on ${Helpers.formatDate(selectedDate!)}',
              style: TextStyle(color: theme.colorScheme.onBackground),
            ),
          );
        }

        final logs = snapshot.data!;

        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final exerciseName = log['exercises']?['name'] ?? 'Unknown Exercise';
            final sets = (log['sets'] as List?) ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sets.asMap().entries.map((entry) {
                        final i = entry.key + 1;
                        final set = entry.value;
                        final w = Helpers.formatWeight(set['weight']);
                        final r = Helpers.formatReps(set['reps']);
                        return Text(
                          "Set $i: $w x $r reps",
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.85),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentLiftsView(SupabaseClient supabase, ThemeData theme) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRecentSessionExercises(supabase),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No recent lifts found.',
              style: TextStyle(color: theme.colorScheme.onBackground),
            ),
          );
        }

        final logs = snapshot.data!;

        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final timestamp = log['sessions']?['timestamp'];
            final exerciseName = log['exercises']?['name'] ?? 'Unknown Exercise';
            final sets = (log['sets'] as List?) ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            exerciseName,
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          Helpers.formatTimestamp(timestamp),
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sets.asMap().entries.map((entry) {
                        final i = entry.key + 1;
                        final set = entry.value;
                        final w = Helpers.formatWeight(set['weight']);
                        final r = Helpers.formatReps(set['reps']);
                        return Text(
                          "Set $i: $w x $r reps",
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.85),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
