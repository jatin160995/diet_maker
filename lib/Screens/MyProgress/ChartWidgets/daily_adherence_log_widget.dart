import 'package:diet_maker/Screens/MyProgress/ChartModels/adherence_chart_data.dart';
import 'package:flutter/material.dart';

class DailyLogWidget extends StatelessWidget {
  final List<DailyLog> logs;

  const DailyLogWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          logs.map((log) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.brown),
                    const SizedBox(width: 8),
                    Text(
                      log.dateFormatted,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      log.meals.map((meal) {
                        Color color;
                        if (meal.isOnPlan == "Yes") {
                          color = Colors.green;
                        } else if (meal.isOnPlan == "No") {
                          color = Colors.red;
                        } else {
                          color = Colors.grey;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color, width: 1),
                          ),
                          child: Text(
                            meal.title,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 15),
              ],
            );
          }).toList(),
    );
  }
}
