class AdherenceChartData {
  final String dateLabel;
  final double percentage;

  AdherenceChartData({required this.dateLabel, required this.percentage});
}

class MealLog {
  final String title;
  final String isOnPlan;

  MealLog({required this.title, required this.isOnPlan});
}

class DailyLog {
  final String dateFormatted;
  final List<MealLog> meals;

  DailyLog({required this.dateFormatted, required this.meals});
}
