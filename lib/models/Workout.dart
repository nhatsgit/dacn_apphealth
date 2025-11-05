import 'package:dacn_app/models/Exercise.dart';

class Workout {
  final int id;
  final String name;
  final String frequency; // daily, 3days,...
  final int targetSteps;
  final String preferredTime; // "06:30:00"
  final String? notes;
  final List<Exercise> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.frequency,
    required this.targetSteps,
    required this.preferredTime,
    this.notes,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      frequency: json['frequency'],
      targetSteps: json['targetSteps'],
      preferredTime: json['preferredTime'],
      notes: json['notes'],
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'frequency': frequency,
      'targetSteps': targetSteps,
      'preferredTime': preferredTime,
      'notes': notes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
