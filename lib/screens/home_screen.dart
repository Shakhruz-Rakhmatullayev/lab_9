import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/charts.dart';
import '../widgets/glass.dart';
import '../widgets/sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  Widget _padded(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final q = _query.trim().toLowerCase();
    final habits = state.habits
        .where((h) => h.title.toLowerCase().contains(q))
        .toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _padded(
              _TopBar(
                name: state.userName,
                onProfile: () => widget.onNavigate(4),
              ),
            ),
            const SizedBox(height: 26),
            _padded(Reveal(child: _Greeting(firstName: state.firstName))),
            const SizedBox(height: 20),
            _padded(
              Reveal(
                delay: const Duration(milliseconds: 80),
                child: _SearchBar(onChanged: (v) => setState(() => _query = v)),
              ),
            ),
            const SizedBox(height: 28),
            _padded(
              SectionHeader(
                title: "Today's stats",
                action: 'View more',
                onAction: () => widget.onNavigate(2),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: todayStats.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => Reveal(
                  delay: Duration(milliseconds: 120 + i * 70),
                  child: _StatCard(item: todayStats[i]),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _padded(
              SectionHeader(
                title: "Today's habits",
                action: '${state.doneCount}/${state.habits.length} done',
                onAction: () => widget.onNavigate(1),
              ),
            ),
            const SizedBox(height: 14),
            if (habits.isEmpty)
              _padded(
                Glass(
                  opacity: 0.12,
                  child: Text(
                    q.isEmpty
                        ? 'No habits yet — add one from the Habits tab.'
                        : 'No habits match "$_query".',
                    style: AppText.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 124,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: habits.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _HabitChip(
                    habit: habits[i],
                    onTap: () => state.toggleHabit(habits[i]),
                  ),
                ),
              ),
            const SizedBox(height: 28),
            _padded(
              SectionHeader(
                title: "Today's workout",
                action: 'View more',
                onAction: () => showWorkoutSheet(context),
              ),
            ),
            const SizedBox(height: 14),
            _padded(
              Reveal(
                delay: const Duration(milliseconds: 220),
                child: _WorkoutCard(onPlay: () => showWorkoutSheet(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.name, required this.onProfile});

  final String name;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        GlassCircleButton(
          icon: Icons.watch_outlined,
          onTap: () => _showList(context, 'Devices', const [
            (
              Icons.watch_rounded,
              'Smart watch',
              'Connected · synced 2 min ago',
            ),
            (Icons.monitor_weight_outlined, 'Smart scale', 'Not paired'),
          ]),
        ),
        const SizedBox(width: 10),
        GlassCircleButton(
          icon: Icons.notifications_none_rounded,
          badge: true,
          onTap: () => _showList(context, 'Notifications', const [
            (
              Icons.local_fire_department_rounded,
              '21-day streak!',
              'You meditated 21 days in a row.',
            ),
            (
              Icons.water_drop_rounded,
              'Hydration check',
              'You are 200 ml away from your goal.',
            ),
            (
              Icons.fitness_center_rounded,
              'Workout ready',
              'Upper body strength is planned today.',
            ),
          ]),
        ),
        const SizedBox(width: 10),
        Pressable(
          onTap: onProfile,
          child: Avatar(name: name, size: 52),
        ),
      ],
    );
  }

  void _showList(
    BuildContext context,
    String title,
    List<(IconData, String, String)> rows,
  ) {
    showGlassSheet<void>(
      context,
      title: title,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Glass(
                radius: 22,
                opacity: 0.14,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconBubble(icon: r.$1, color: AppColors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.$2,
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(r.$3, style: AppText.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 26,
              height: 1.3,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.3,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            children: [
              const TextSpan(text: 'Welcome, '),
              TextSpan(
                text: '$firstName! ',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const TextSpan(text: "here's your\n"),
              const TextSpan(
                text: 'habit snapshot for today!',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Today is ${formatLongDate(DateTime.now())}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 32,
      opacity: 0.2,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration.collapsed(
                hintText: 'Search habits...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final StatItem item;

  @override
  Widget build(BuildContext context) {
    return Glass(
      width: 164,
      height: 180,
      radius: 26,
      opacity: 0.58,
      borderOpacity: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.ink.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: item.value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' ${item.unit}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.ink),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(child: StatusChip(label: item.badge)),
              ),
              const SizedBox(width: 6),
              ProgressRing(progress: item.progress, icon: item.icon, size: 58),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitChip extends StatelessWidget {
  const _HabitChip({required this.habit, required this.onTap});

  final Habit habit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = habit.done;
    final fg = done ? AppColors.ink : Colors.white;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: done ? 0.9 : 0.14),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: habit.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(habit.icon, color: Colors.white, size: 18),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(done),
                    color: done
                        ? AppColors.ink
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              habit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 13,
                  color: AppColors.orange,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    '${habit.streak} day streak',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: fg.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Glass(
      height: 196,
      radius: 30,
      opacity: 0.55,
      borderOpacity: 0.6,
      padding: EdgeInsets.zero,
      onTap: onPlay,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -30,
            bottom: -30,
            width: 220,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.inkSoft.withValues(alpha: 0.55),
                    AppColors.inkSoft.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 30,
            child: Transform.rotate(
              angle: -0.6,
              child: Icon(
                Icons.fitness_center_rounded,
                size: 120,
                color: AppColors.ink.withValues(alpha: 0.85),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upper body\nstrength',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${workoutExercises.length} exercises',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.ink.withValues(alpha: 0.65),
                  ),
                ),
                const Spacer(),
                const Row(
                  children: [
                    _InfoChip(icon: Icons.timer_outlined, label: '45 min'),
                    SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.local_fire_department_rounded,
                      label: '350 Cal',
                      iconColor: AppColors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.ink,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.ink,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

void showWorkoutSheet(BuildContext context) {
  showGlassSheet<void>(
    context,
    title: 'Upper body strength',
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: workoutExercises.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final (name, sets) = workoutExercises[i];
              return Glass(
                radius: 22,
                opacity: 0.14,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(sets, style: AppText.caption),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Start workout',
          icon: Icons.play_arrow_rounded,
          onTap: () {
            Navigator.pop(sheetContext);
            showToast(context, "Workout started — let's go!");
          },
        ),
      ],
    ),
  );
}
