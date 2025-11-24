// File: lib/models/WorkoutPlan.dart

// --- 1. Chi tiết một bài tập trong kế hoạch (Tương ứng với WorkoutExerciseDto) ---
class WorkoutExercise {
  final int id;
  final int exerciseId;
  final String
      exerciseName; // Lấy từ ThenInclude(e => e.Exercise) trong C# Controller
  final int? durationMinutes;
  final int? sets;
  final int? reps;
  final String? dayOfWeek; // 1=Thứ 2, 7=Chủ nhật
  final String? notes;

  WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.durationMinutes,
    this.sets,
    this.reps,
    this.dayOfWeek,
    this.notes,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as int,
      exerciseId: json['exerciseId'] as int,
      exerciseName: json['exerciseName'] as String,
      durationMinutes: json['durationMinutes'] as int?,
      sets: json['sets'] as int?,
      reps: json['reps'] as int?,
      dayOfWeek: json['dayOfWeek'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

// --- 2. Kế hoạch tập luyện chính (Tương ứng với WorkoutPlanDto) ---
class WorkoutPlan {
  final int id;
  final String name;
  final String? frequency; // Ví dụ: 'Daily', '3 times a week'
  final int? targetSteps;
  final String? preferredTime; // Ví dụ: 'Morning'
  final String? notes;
  final List<WorkoutExercise> exercises;

  WorkoutPlan({
    required this.id,
    required this.name,
    this.frequency,
    this.targetSteps,
    this.preferredTime,
    this.notes,
    required this.exercises,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    var exercisesList = json['exercises'] as List<dynamic>?;
    List<WorkoutExercise> exercises = exercisesList
            ?.map((i) => WorkoutExercise.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];

    return WorkoutPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      frequency: json['frequency'] as String?,
      targetSteps: json['targetSteps'] as int?,
      preferredTime: json['preferredTime'] as String?,
      notes: json['notes'] as String?,
      exercises: exercises,
    );
  }
}

// --- 3. DTO cho việc tạo/cập nhật Chi tiết bài tập (Tương ứng với CreateWorkoutExerciseDto) ---
class CreateWorkoutExerciseDto {
  final int exerciseId;
  final int? durationMinutes;
  final int? sets;
  final int? reps;
  final String? dayOfWeek;
  final String? notes;

  CreateWorkoutExerciseDto({
    required this.exerciseId,
    this.durationMinutes,
    this.sets,
    this.reps,
    this.dayOfWeek,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'durationMinutes': durationMinutes,
      'sets': sets,
      'reps': reps,
      'dayOfWeek': dayOfWeek,
      'notes': notes,
    };
  }
}

// --- 4. DTO cho việc tạo/cập nhật Kế hoạch tập luyện (Tương ứng với CreateWorkoutPlanDto) ---
class CreateWorkoutPlanDto {
  final String name;
  final String? frequency;
  final int? targetSteps;
  final String? preferredTime;
  final String? notes;
  final List<CreateWorkoutExerciseDto> exercises;

  CreateWorkoutPlanDto({
    required this.name,
    this.frequency,
    this.targetSteps,
    this.preferredTime,
    this.notes,
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'frequency': frequency,
      'targetSteps': targetSteps,
      'preferredTime': preferredTime,
      'notes': notes,
      // Đảm bảo gọi toJson() cho danh sách con
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
