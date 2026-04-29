// class DietaryPreference {
//   final int id;
//   final int clientId;
//   final String title;
//   final int noOfMeals;
//   final double weightKg;
//   final double weightKgAchieved;
//   final int weightLbs;
//   final int weightLbsAchieved;
//   final int heightIn;
//   final double heightCm;
//   final String dob;
//   final int age;
//   final double activityLevel;
//   final String physicalGoal;
//   final String percentageOrWeight;
//   final int dailyCalorieDeficitOrSurplus;
//   final int avgCalorieToMaintainWeight;
//   final int dailyCalorieIntake;
//   final int avgCalorieDifference;
//   final int proteinPercentage;
//   final int carbohydratePercentage;
//   final int fatPercentage;
//   final int proteinRequired;
//   final int carbohydrateRequired;
//   final int fatRequired;
//   final int stepsCompleted;
//   final String isScheduled;
//   final String status;
//   final String createdAt;
//   final String updatedAt;
//   final String dailyCalorieDeficitOrSurplusLabel;
//   final int noOfMealPlans;
//   final int primaryMealPlanId;
//   final String createdAtFormatted;
//   final String activityLevelTitle;
//   final String heightFeet;

//   DietaryPreference({
//     required this.id,
//     required this.clientId,
//     required this.title,
//     required this.noOfMeals,
//     required this.weightKg,
//     required this.weightKgAchieved,
//     required this.weightLbs,
//     required this.weightLbsAchieved,
//     required this.heightIn,
//     required this.heightCm,
//     required this.dob,
//     required this.age,
//     required this.activityLevel,
//     required this.physicalGoal,
//     required this.percentageOrWeight,
//     required this.dailyCalorieDeficitOrSurplus,
//     required this.avgCalorieToMaintainWeight,
//     required this.dailyCalorieIntake,
//     required this.avgCalorieDifference,
//     required this.proteinPercentage,
//     required this.carbohydratePercentage,
//     required this.fatPercentage,
//     required this.proteinRequired,
//     required this.carbohydrateRequired,
//     required this.fatRequired,
//     required this.stepsCompleted,
//     required this.isScheduled,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.dailyCalorieDeficitOrSurplusLabel,
//     required this.noOfMealPlans,
//     required this.primaryMealPlanId,
//     required this.createdAtFormatted,
//     required this.activityLevelTitle,
//     required this.heightFeet,
//   });

//   factory DietaryPreference.fromJson(Map<String, dynamic> json) =>
//       DietaryPreference(
//         id: json['id'] ?? 0,
//         clientId: json['client_id'] ?? 0,
//         title: json['title'] ?? '',
//         noOfMeals: int.parse(json['no_of_meals'].toString()) ?? 0,
//         weightKg: json['weight_kg'].toDouble() ?? 0,
//         weightKgAchieved: json['weight_kg_achieved'].toDouble() ?? 0,
//         weightLbs: json['weight_lbs'] ?? 0,
//         weightLbsAchieved: json['weight_lbs_achieved'] ?? 0,
//         heightIn: json['height_in'] ?? 0,
//         heightCm: json['height_cm'].toDouble() ?? 0,
//         dob: json['dob'] ?? '',
//         age: json['age'] ?? 0,
//         activityLevel: json['activity_level'].toDouble() ?? 0.0,
//         physicalGoal: json['physical_goal'] ?? '',
//         percentageOrWeight: json['percentage_or_weight'] ?? '',
//         dailyCalorieDeficitOrSurplus:
//             json['daily_calorie_deficit_or_surplus'] ?? 0,
//         avgCalorieToMaintainWeight: json['avg_calorie_to_maintain_weight'] ?? 0,
//         dailyCalorieIntake: json['daily_calorie_intake'] ?? 0,
//         avgCalorieDifference: json['avg_calorie_difference'] ?? 0,
//         proteinPercentage: json['protein_percentage'] ?? 0,
//         carbohydratePercentage: json['carbohydrate_percentage'] ?? 0,
//         fatPercentage: json['fat_percentage'] ?? 0,
//         proteinRequired: json['protein_required'] ?? 0,
//         carbohydrateRequired: json['carbohydrate_required'] ?? 0,
//         fatRequired: json['fat_required'] ?? 0,
//         stepsCompleted: json['steps_completed'] ?? 0,
//         isScheduled: json['is_scheduled'] ?? '',
//         status: json['status'] ?? '',
//         createdAt: json['created_at'] ?? '',
//         updatedAt: json['updated_at'] ?? '',
//         dailyCalorieDeficitOrSurplusLabel:
//             json['daily_calorie_deficit_or_surplus_label'] ?? '',
//         noOfMealPlans: json['no_of_meal_plans'] ?? 0,
//         primaryMealPlanId: json['primary_meal_plan_id'] ?? 0,
//         createdAtFormatted: json['created_at_formatted'] ?? '',
//         activityLevelTitle: json['activity_level_title'] ?? '',
//         heightFeet: json['height_feet'] ?? '',
//       );

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'client_id': clientId,
//     'title': title,
//     'no_of_meals': noOfMeals,
//     'weight_kg': weightKg,
//     'weight_kg_achieved': weightKgAchieved,
//     'weight_lbs': weightLbs,
//     'weight_lbs_achieved': weightLbsAchieved,
//     'height_in': heightIn,
//     'height_cm': heightCm,
//     'dob': dob,
//     'age': age,
//     'activity_level': activityLevel,
//     'physical_goal': physicalGoal,
//     'percentage_or_weight': percentageOrWeight,
//     'daily_calorie_deficit_or_surplus': dailyCalorieDeficitOrSurplus,
//     'avg_calorie_to_maintain_weight': avgCalorieToMaintainWeight,
//     'daily_calorie_intake': dailyCalorieIntake,
//     'avg_calorie_difference': avgCalorieDifference,
//     'protein_percentage': proteinPercentage,
//     'carbohydrate_percentage': carbohydratePercentage,
//     'fat_percentage': fatPercentage,
//     'protein_required': proteinRequired,
//     'carbohydrate_required': carbohydrateRequired,
//     'fat_required': fatRequired,
//     'steps_completed': stepsCompleted,
//     'is_scheduled': isScheduled,
//     'status': status,
//     'created_at': createdAt,
//     'updated_at': updatedAt,
//     'daily_calorie_deficit_or_surplus_label': dailyCalorieDeficitOrSurplusLabel,
//     'no_of_meal_plans': noOfMealPlans,
//     'primary_meal_plan_id': primaryMealPlanId,
//     'created_at_formatted': createdAtFormatted,
//     'activity_level_title': activityLevelTitle,
//     'height_feet': heightFeet,
//   };
// }

class DietaryPreference {
  int id;
  int clientId;
  String title;
  int noOfMeals;
  double weightKg;
  double weightKgAchieved;
  int weightLbs;
  int weightLbsAchieved;
  int heightIn;
  double heightCm;
  String dob;
  int age;
  double activityLevel;
  String physicalGoal;
  String percentageOrWeight;
  int dailyCalorieDeficitOrSurplus;
  int avgCalorieToMaintainWeight;
  int dailyCalorieIntake;
  int avgCalorieDifference;
  int proteinPercentage;
  int carbohydratePercentage;
  int fatPercentage;
  int proteinRequired;
  int carbohydrateRequired;
  int fatRequired;
  int stepsCompleted;
  String isScheduled;
  String status;
  String createdAt;
  String updatedAt;
  String dailyCalorieDeficitOrSurplusLabel;
  int noOfMealPlans;
  int primaryMealPlanId;
  String createdAtFormatted;
  String activityLevelTitle;
  String heightFeet;

  DietaryPreference({
    required this.id,
    required this.clientId,
    required this.title,
    required this.noOfMeals,
    required this.weightKg,
    required this.weightKgAchieved,
    required this.weightLbs,
    required this.weightLbsAchieved,
    required this.heightIn,
    required this.heightCm,
    required this.dob,
    required this.age,
    required this.activityLevel,
    required this.physicalGoal,
    required this.percentageOrWeight,
    required this.dailyCalorieDeficitOrSurplus,
    required this.avgCalorieToMaintainWeight,
    required this.dailyCalorieIntake,
    required this.avgCalorieDifference,
    required this.proteinPercentage,
    required this.carbohydratePercentage,
    required this.fatPercentage,
    required this.proteinRequired,
    required this.carbohydrateRequired,
    required this.fatRequired,
    required this.stepsCompleted,
    required this.isScheduled,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.dailyCalorieDeficitOrSurplusLabel,
    required this.noOfMealPlans,
    required this.primaryMealPlanId,
    required this.createdAtFormatted,
    required this.activityLevelTitle,
    required this.heightFeet,
  });

  factory DietaryPreference.fromJson(Map<String, dynamic> json) =>
      DietaryPreference(
        id: json['id'] ?? 0,
        clientId: json['client_id'] ?? 0,
        title: json['title'] ?? '',
        noOfMeals: int.tryParse(json['no_of_meals'].toString()) ?? 0,
        weightKg: (json['weight_kg'] ?? 0).toDouble(),
        weightKgAchieved: (json['weight_kg_achieved'] ?? 0).toDouble(),
        weightLbs: int.tryParse(json['weight_lbs'].toString()) ?? 0,
        weightLbsAchieved:
            int.tryParse(json['weight_lbs_achieved'].toString()) ?? 0,
        heightIn: int.tryParse(json['height_in'].toString()) ?? 0,
        heightCm: (json['height_cm'] ?? 0).toDouble(),
        dob: json['dob'] ?? '',
        age: json['age'] ?? 0,
        activityLevel: (json['activity_level'] ?? 0).toDouble(),
        physicalGoal: json['physical_goal'] ?? '',
        percentageOrWeight: json['percentage_or_weight'] ?? '',
        dailyCalorieDeficitOrSurplusLabel:
            json['daily_calorie_deficit_or_surplus_label'] ?? '',
        dailyCalorieDeficitOrSurplus:
            json['daily_calorie_deficit_or_surplus'] ?? 0,
        avgCalorieToMaintainWeight: json['avg_calorie_to_maintain_weight'] ?? 0,
        dailyCalorieIntake: json['daily_calorie_intake'] ?? 0,
        avgCalorieDifference: json['avg_calorie_difference'] ?? 0,
        proteinPercentage: json['protein_percentage'] ?? 0,
        carbohydratePercentage: json['carbohydrate_percentage'] ?? 0,
        fatPercentage: json['fat_percentage'] ?? 0,
        proteinRequired: json['protein_required'] ?? 0,
        carbohydrateRequired: json['carbohydrate_required'] ?? 0,
        fatRequired: json['fat_required'] ?? 0,
        stepsCompleted: json['steps_completed'] ?? 0,
        isScheduled: json['is_scheduled'] ?? '',
        status: json['status'] ?? '',
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',

        noOfMealPlans: json['no_of_meal_plans'] ?? 0,
        primaryMealPlanId: json['primary_meal_plan_id'] ?? 0,
        createdAtFormatted: json['created_at_formatted'] ?? '',
        activityLevelTitle: json['activity_level_title'] ?? '',
        heightFeet: json['height_feet'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'client_id': clientId,
    'title': title,
    'no_of_meals': noOfMeals,
    'weight_kg': weightKg,
    'weight_kg_achieved': weightKgAchieved,
    'weight_lbs': weightLbs,
    'weight_lbs_achieved': weightLbsAchieved,
    'height_in': heightIn,
    'height_cm': heightCm,
    'dob': dob,
    'age': age,
    'activity_level': activityLevel,
    'physical_goal': physicalGoal,
    'percentage_or_weight': percentageOrWeight,
    'daily_calorie_deficit_or_surplus': dailyCalorieDeficitOrSurplus,
    'avg_calorie_to_maintain_weight': avgCalorieToMaintainWeight,
    'daily_calorie_intake': dailyCalorieIntake,
    'avg_calorie_difference': avgCalorieDifference,
    'protein_percentage': proteinPercentage,
    'carbohydrate_percentage': carbohydratePercentage,
    'fat_percentage': fatPercentage,
    'protein_required': proteinRequired,
    'carbohydrate_required': carbohydrateRequired,
    'fat_required': fatRequired,
    'steps_completed': stepsCompleted,
    'is_scheduled': isScheduled,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'daily_calorie_deficit_or_surplus_label': dailyCalorieDeficitOrSurplusLabel,
    'no_of_meal_plans': noOfMealPlans,
    'primary_meal_plan_id': primaryMealPlanId,
    'created_at_formatted': createdAtFormatted,
    'activity_level_title': activityLevelTitle,
    'height_feet': heightFeet,
  };

  // 🔧 --- Setters for single values ---
  void setTitle(String value) => title = value;
  void setNoOfMeals(int value) => noOfMeals = value;
  void setWeightKg(double value) => weightKg = value;
  void setWeightKgAchieved(double value) => weightKgAchieved = value;
  void setWeightLbs(int value) => weightLbs = value;
  void setWeightLbsAchieved(int value) => weightLbsAchieved = value;
  void setHeightIn(int value) => heightIn = value;
  void setHeightCm(double value) => heightCm = value;
  void setDob(String value) => dob = value;
  void setAge(int value) => age = value;
  void setActivityLevel(double value) => activityLevel = value;
  void setPhysicalGoal(String value) => physicalGoal = value;
  void setPercentageOrWeight(String value) => percentageOrWeight = value;
  void setDailyCalorieDeficitOrSurplus(int value) =>
      dailyCalorieDeficitOrSurplus = value;
  void setAvgCalorieToMaintainWeight(int value) =>
      avgCalorieToMaintainWeight = value;
  void setDailyCalorieIntake(int value) => dailyCalorieIntake = value;
  void setAvgCalorieDifference(int value) => avgCalorieDifference = value;
  void setProteinPercentage(int value) => proteinPercentage = value;
  void setCarbohydratePercentage(int value) => carbohydratePercentage = value;
  void setFatPercentage(int value) => fatPercentage = value;
  void setProteinRequired(int value) => proteinRequired = value;
  void setCarbohydrateRequired(int value) => carbohydrateRequired = value;
  void setFatRequired(int value) => fatRequired = value;
  void setStepsCompleted(int value) => stepsCompleted = value;
  void setIsScheduled(String value) => isScheduled = value;
  void setStatus(String value) => status = value;
  void setDailyCalorieDeficitOrSurplusLabel(String value) =>
      dailyCalorieDeficitOrSurplusLabel = value;
  void setNoOfMealPlans(int value) => noOfMealPlans = value;
  void setPrimaryMealPlanId(int value) => primaryMealPlanId = value;
  void setActivityLevelTitle(String value) => activityLevelTitle = value;
  void setHeightFeet(String value) => heightFeet = value;
}
