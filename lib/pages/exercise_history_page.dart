import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../custom_widgets.dart';
import '../helpers.dart';
import '../styles/text_styles.dart';
import 'log_workout_page.dart';

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
  bool showCalendar = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

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
      showCalendar = false;
    });
  }

  void _toggleCalendar() {
    setState(() {
      showCalendar = !showCalendar;
      showRecentLifts = false;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
      _focusedDay = focusedDay;
      showCalendar = false;
      
      // Update currentDateIndex if the selected date is in availableDates
      final index = availableDates.indexWhere((date) => 
        date.year == selectedDay.year && 
        date.month == selectedDay.month && 
        date.day == selectedDay.day
      );
      if (index != -1) {
        currentDateIndex = index;
      }
    });
  }

  bool _hasWorkoutOnDate(DateTime date) {
    return availableDates.any((availableDate) => 
      availableDate.year == date.year && 
      availableDate.month == date.month && 
      availableDate.day == date.day
    );
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
          // Recent Lifts Toggle Button - always visible
          if (availableDates.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        style: AppTextStyles.withColor(AppTextStyles.buttonSecondary, theme.colorScheme.onSecondary),
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
          ],
          
          // Calendar Widget
          if (showCalendar) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
              ),
              child: TableCalendar<dynamic>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: (day) {
                  return _hasWorkoutOnDate(day) ? ['workout'] : [];
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: theme.colorScheme.onSurface),
                  defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
                  holidayTextStyle: TextStyle(color: theme.colorScheme.onSurface),
                  selectedTextStyle: TextStyle(color: theme.colorScheme.onPrimary),
                  todayTextStyle: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  markerSize: 6,
                  markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: theme.colorScheme.onSecondary,
                  ),
                  titleTextStyle: AppTextStyles.withColor(AppTextStyles.cardTitle, theme.colorScheme.onSurface),
                ),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Date Selector - only show when not in recent lifts mode and calendar is hidden
          if (availableDates.isNotEmpty && !showRecentLifts && !showCalendar) ...[
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
                    onTap: _toggleCalendar,
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
                        style: AppTextStyles.withColor(AppTextStyles.dateSelector, theme.colorScheme.onBackground),
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
    final hasWorkout = _hasWorkoutOnDate(selectedDate!);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getSessionExercisesForDate(supabase, startOfDay, endOfDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // No workout logged for this date - show option to start new workout
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No workout logged on ${Helpers.formatDate(selectedDate!)}',
                  style: AppTextStyles.withColor(AppTextStyles.cardTitle, theme.colorScheme.onBackground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start logging your workout for this day',
                  style: AppTextStyles.withOpacity(AppTextStyles.cardSubtitle, theme.colorScheme.onBackground, 0.7),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogWorkoutPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Log Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
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

            return GymPalCard(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: AppTextStyles.withColor(AppTextStyles.cardTitle, theme.colorScheme.onBackground),
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
                        "Set $i: $w x $r",
                        style: AppTextStyles.withOpacity(AppTextStyles.cardSubtitle, theme.colorScheme.onBackground, 0.85),
                      );
                    }).toList(),
                  )
                ],
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

        // Group logs by date
        final groupedLogs = <String, List<Map<String, dynamic>>>{};
        for (final log in logs) {
          final timestamp = log['sessions']?['timestamp'];
          if (timestamp != null) {
            final date = DateTime.parse(timestamp);
            final dateKey = DateTime(date.year, date.month, date.day).toIso8601String();
            groupedLogs.putIfAbsent(dateKey, () => []).add(log);
          }
        }
        
        // Sort dates (most recent first)
        final sortedDates = groupedLogs.keys.toList()
          ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));
        
        // Create list items with date headers and cards
        final listItems = <Widget>[];
        for (final dateKey in sortedDates) {
          final date = DateTime.parse(dateKey);
          final dateLogs = groupedLogs[dateKey]!;
          
          // Add date header
          listItems.add(
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                Helpers.formatDate(date),
                style: AppTextStyles.withColor(AppTextStyles.dateHeader, theme.colorScheme.onBackground),
              ),
            ),
          );
          
          // Add exercise cards for this date
          for (final log in dateLogs) {
            final exerciseName = log['exercises']?['name'] ?? 'Unknown Exercise';
            final sets = (log['sets'] as List?) ?? [];

            listItems.add(
              GymPalCard(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: AppTextStyles.withColor(AppTextStyles.cardTitle, theme.colorScheme.onBackground),
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
                          style: AppTextStyles.withOpacity(AppTextStyles.cardSubtitle, theme.colorScheme.onBackground, 0.85),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            );
          }
        }

        return ListView(
          children: listItems,
        );
      },
    );
  }
}
