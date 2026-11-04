import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/data/sample_data.dart';
import 'package:habitflow/main.dart';
import 'package:habitflow/state/app_state.dart';
import 'package:habitflow/utils/format.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1179, 2556); // iPhone 15 Pro
    view.devicePixelRatio = 3;
  });

  testWidgets('every tab renders without layout errors', (tester) async {
    await tester.pumpWidget(HabitflowApp(state: AppState()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Welcome'), findsOneWidget);

    for (final (icon, title) in [
      (Icons.assignment_outlined, 'Habits'),
      (Icons.leaderboard_outlined, 'Statistic'),
      (Icons.storefront_outlined, 'Catalog'),
      (Icons.person_outline_rounded, 'Profile'),
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets);
    }
  });

  testWidgets('toggling a habit updates the done count', (tester) async {
    final state = AppState();
    await tester.pumpWidget(HabitflowApp(state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.assignment_outlined));
    await tester.pumpAndSettle();

    final before = state.doneCount;
    await tester.tap(find.text('Read 20 pages'));
    await tester.pumpAndSettle();
    expect(state.doneCount, before + 1);
  });

  testWidgets('catalog toggles views, deletes with undo and reloads', (
    tester,
  ) async {
    await tester.pumpWidget(HabitflowApp(state: AppState()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await tester.pumpAndSettle();
    expect(find.text('List feed'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    await tester.tap(find.byIcon(Icons.view_list_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsNothing);

    final first = seedProducts.first.title;
    await tester.drag(find.text(first), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text(first), findsNothing);
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(find.text(first), findsOneWidget);

    await tester.drag(find.text(first), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('${seedProducts.length - 1} items'), findsOneWidget);
    await tester.fling(
      find.text(seedProducts[1].title),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text(first), findsOneWidget);
    expect(find.text('${seedProducts.length} items'), findsOneWidget);
  });

  testWidgets('empty catalog can be restored', (tester) async {
    await tester.pumpWidget(HabitflowApp(state: AppState()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await tester.pumpAndSettle();

    for (final p in seedProducts) {
      await tester.drag(find.text(p.title), const Offset(-500, 0));
      await tester.pumpAndSettle();
    }
    expect(find.text('Catalog is Empty'), findsOneWidget);

    await tester.tap(find.text('Restore catalog'));
    await tester.pumpAndSettle();
    expect(find.text(seedProducts.first.title), findsOneWidget);
  });

  testWidgets('cart syncs between catalog and cart screen', (tester) async {
    await tester.pumpWidget(HabitflowApp(state: AppState()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Add to Cart'), findsNWidgets(6));

    final [a, b, ..._] = seedProducts;
    await tester.tap(find.text('Add to Cart').at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to Cart').at(0));
    await tester.pumpAndSettle();
    expect(find.text('In cart'), findsNWidgets(2));
    expect(find.text('2'), findsOneWidget); // AppBar badge

    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Total (2 items)'), findsOneWidget);
    expect(find.text(formatPrice(a.price + b.price)), findsOneWidget);

    await tester.tap(find.byTooltip('Remove ${a.title}'));
    await tester.pumpAndSettle();
    expect(find.text('Total (1 items)'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('In cart'), findsOneWidget);
    expect(find.text('Add to Cart'), findsNWidgets(5));

    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear All').last);
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.tap(find.text('Back to catalog'));
    await tester.pumpAndSettle();
    expect(find.text('In cart'), findsNothing);
    expect(find.text('Add to Cart'), findsNWidgets(6));
  });

  test('settings survive an app restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    AppState(prefs: prefs)
      ..setThemeMode(ThemeMode.dark)
      ..setSound(false)
      ..setReminder(const TimeOfDay(hour: 21, minute: 30))
      ..toggleCaution('Knees');

    final restarted = AppState(prefs: prefs);
    expect(restarted.themeMode, ThemeMode.dark);
    expect(restarted.sound, isFalse);
    expect(restarted.reminder, const TimeOfDay(hour: 21, minute: 30));
    expect(restarted.cautionAreas, containsAll(['Lower back', 'Knees']));
  });
}
