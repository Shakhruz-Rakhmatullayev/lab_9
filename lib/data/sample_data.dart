import 'package:flutter/material.dart';

import '../utils/format.dart';

class StatItem {
  const StatItem({
    required this.title,
    required this.value,
    required this.unit,
    required this.badge,
    required this.progress,
    required this.icon,
  });

  final String title;
  final String value;
  final String unit;
  final String badge;
  final double progress;
  final IconData icon;
}

const todayStats = [
  StatItem(
    title: 'Steps to goal',
    value: '5,400',
    unit: 'steps',
    badge: 'Good',
    progress: 0.54,
    icon: Icons.directions_walk_rounded,
  ),
  StatItem(
    title: 'Cal burnt',
    value: '312',
    unit: 'kcal',
    badge: 'Average',
    progress: 0.62,
    icon: Icons.local_fire_department_rounded,
  ),
  StatItem(
    title: 'Water',
    value: '1.8',
    unit: 'liters',
    badge: 'Good',
    progress: 0.72,
    icon: Icons.water_drop_rounded,
  ),
  StatItem(
    title: 'Sleep',
    value: '7h 20',
    unit: 'min',
    badge: 'Great',
    progress: 0.9,
    icon: Icons.bedtime_rounded,
  ),
];

enum Metric { steps, heart, regularity }

extension MetricInfo on Metric {
  String get label => switch (this) {
    Metric.steps => 'Steps',
    Metric.heart => 'Heart',
    Metric.regularity => 'Regularity',
  };

  IconData get icon => switch (this) {
    Metric.steps => Icons.directions_walk_rounded,
    Metric.heart => Icons.favorite_border_rounded,
    Metric.regularity => Icons.leaderboard_outlined,
  };

  String get caption => switch (this) {
    Metric.steps => 'average steps',
    Metric.heart => 'average bpm',
    Metric.regularity => 'habits completed',
  };

  String format(double v) => switch (this) {
    Metric.steps => formatThousands(v),
    Metric.heart => '${v.round()}',
    Metric.regularity => '${v.round()}%',
  };
}

const chartDays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
const chartPeriods = ['This Week', 'Last Week', '2 Weeks Ago'];

const Map<Metric, List<List<double>>> chartData = {
  Metric.steps: [
    [3900, 6200, 3100, 5600, 9400, 4800, 4200],
    [5200, 4100, 6900, 3800, 4500, 7600, 5100],
    [2800, 3600, 4400, 6100, 5300, 3900, 8200],
  ],
  Metric.heart: [
    [72, 78, 70, 81, 88, 75, 74],
    [69, 74, 77, 73, 70, 82, 76],
    [75, 71, 68, 79, 74, 77, 85],
  ],
  Metric.regularity: [
    [67, 83, 50, 100, 83, 67, 83],
    [50, 67, 83, 67, 100, 50, 67],
    [33, 50, 67, 50, 83, 67, 100],
  ],
};

const workoutExercises = [
  ('Push-ups', '3 × 12'),
  ('Dumbbell bench press', '4 × 10'),
  ('Bent-over row', '4 × 10'),
  ('Shoulder press', '3 × 12'),
  ('Bicep curls', '3 × 15'),
  ('Tricep dips', '3 × 12'),
];

const habitIconChoices = [
  Icons.water_drop_rounded,
  Icons.self_improvement_rounded,
  Icons.menu_book_rounded,
  Icons.directions_run_rounded,
  Icons.bedtime_rounded,
  Icons.restaurant_rounded,
  Icons.edit_note_rounded,
  Icons.spa_rounded,
];

const habitColorChoices = [
  Color(0xFFF0782A),
  Color(0xFF3C8D7E),
  Color(0xFF5B7DB1),
  Color(0xFFB4637A),
  Color(0xFF8A7A4E),
];

const habitTimes = ['Morning', 'Afternoon', 'Evening', 'Anytime'];

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.price,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String category;
  final double rating;
  final double price;
  final IconData icon;
  final Color color;
}

const seedProducts = [
  Product(
    id: 'yoga-mat',
    title: 'Cork yoga mat',
    category: 'Fitness',
    rating: 4.8,
    price: 39.99,
    icon: Icons.self_improvement_rounded,
    color: Color(0xFF3C8D7E),
  ),
  Product(
    id: 'bands',
    title: 'Resistance band set',
    category: 'Fitness',
    rating: 4.6,
    price: 24.50,
    icon: Icons.fitness_center_rounded,
    color: Color(0xFFF0782A),
  ),
  Product(
    id: 'bottle',
    title: 'Smart water bottle',
    category: 'Hydration',
    rating: 4.3,
    price: 49.00,
    icon: Icons.water_drop_rounded,
    color: Color(0xFF5B7DB1),
  ),
  Product(
    id: 'roller',
    title: 'Foam roller',
    category: 'Recovery',
    rating: 4.5,
    price: 19.99,
    icon: Icons.spa_rounded,
    color: Color(0xFFB4637A),
  ),
  Product(
    id: 'journal',
    title: 'Habit journal',
    category: 'Mindfulness',
    rating: 4.9,
    price: 14.00,
    icon: Icons.edit_note_rounded,
    color: Color(0xFF8A7A4E),
  ),
  Product(
    id: 'sleep-mask',
    title: 'Contour sleep mask',
    category: 'Sleep',
    rating: 4.4,
    price: 17.50,
    icon: Icons.bedtime_rounded,
    color: Color(0xFF5E6A9E),
  ),
];
