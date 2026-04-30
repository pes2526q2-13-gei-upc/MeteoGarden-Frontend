class Mission {
  final String title;
  final String description;
  final int progress;
  final int goal;
  final int reward;

  Mission({
    required this.title,
    required this.description,
    required this.progress,
    required this.goal,
    required this.reward,
  });
  double get percentage => progress / goal;

  bool get isCompleted => progress >= goal;
}