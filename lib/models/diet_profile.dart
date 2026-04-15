import 'dart:convert';

class DietProfile {
  final int age;
  final String goal;
  final List<String> restrictions;

  DietProfile({
    required this.age,
    required this.goal,
    required this.restrictions,
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'goal': goal,
        'restrictions': restrictions,
      };

  factory DietProfile.fromJson(Map<String, dynamic> json) => DietProfile(
        age: json['age'] as int,
        goal: json['goal'] as String,
        restrictions: List<String>.from(json['restrictions'] as List),
      );

  String toPromptContext() {
    final restrictionText =
        restrictions.isEmpty || restrictions.contains('None')
            ? 'no specific dietary restrictions'
            : restrictions.join(', ');
    return 'User profile: Age $age, Goal: $goal, Dietary restrictions: $restrictionText.';
  }
}
