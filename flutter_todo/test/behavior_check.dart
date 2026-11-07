// flutter test test/behavior_check.dart — после реализации TODO 1–4.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_navigation_task/main.dart';
import 'font_setup.dart';

void main() {
  setUpAll(loadTestFonts);

  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TodoPage()));
    await tester.pumpAndSettle();
  }

  Future<void> openForm(WidgetTester tester) async {
    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  }

  Future<void> add(WidgetTester tester, String title) async {
    await openForm(tester);
    await tester.enterText(find.byType(TextField), title);
    await tester.ensureVisible(find.text('Сохранить'));
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
  }

  Future<void> askDelete(WidgetTester tester, Finder tile) async {
    await tester.drag(tile, const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить').hitTestable());
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  testWidgets('свайп показывает действие, но сам не удаляет', (tester) async {
    await launch(tester);
    expect(find.text('Удалить').hitTestable(), findsNothing);
    final row = find.widgetWithText(ListTile, 'Повторить Navigator');
    await tester.drag(row, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Удалить').hitTestable(), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(2));
    await tester.tap(find.text('Удалить').hitTestable());
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(row, findsOneWidget);
  });

  testWidgets('добавление возвращает обрезанное название', (tester) async {
    await launch(tester);
    await add(tester, '  Купить молоко  ');
    expect(find.byType(AddTodoPage), findsNothing);
    expect(find.text('Купить молоко'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
  });

  testWidgets('Back закрывает форму без добавления', (tester) async {
    await launch(tester);
    await openForm(tester);
    await tester.enterText(find.byType(TextField), 'Не сохранять');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Не сохранять'), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('пустое название не сохраняется, ошибку можно исправить', (
    tester,
  ) async {
    await launch(tester);
    await openForm(tester);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTodoPage), findsOneWidget);
    expect(find.text('Введите название'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Новая задача');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Новая задача'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
  });

  for (final closeWithBack in [false, true]) {
    testWidgets('отмена удаления: ${closeWithBack ? "Back" : "кнопка"}', (
      tester,
    ) async {
      await launch(tester);
      final row = find.widgetWithText(ListTile, 'Повторить Navigator');
      await askDelete(tester, row);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Повторить Navigator'),
        ),
        findsOneWidget,
      );
      if (closeWithBack) {
        final context = tester.element(find.byType(AlertDialog));
        Navigator.pop(context);
      } else {
        await tester.tap(find.text('Отмена'));
      }
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(row, findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });
  }

  testWidgets('подтверждение удаляет только выбранную задачу', (tester) async {
    await launch(tester);
    await askDelete(
      tester,
      find.widgetWithText(ListTile, 'Повторить Navigator'),
    );
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(find.text('Повторить Navigator'), findsNothing);
    expect(find.text('Подготовить презентацию'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('одинаковые названия остаются разными задачами', (tester) async {
    await launch(tester);
    await add(tester, 'Повторить Navigator');
    final rows = find.widgetWithText(ListTile, 'Повторить Navigator');
    expect(rows, findsNWidgets(2));
    await askDelete(tester, rows.last);
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(rows, findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('пустой список и повторное добавление', (tester) async {
    await launch(tester);
    for (var i = 0; i < 2; i++) {
      await askDelete(tester, find.byType(ListTile).first);
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Пока нет задач'), findsOneWidget);
    await add(tester, 'Начать заново');
    expect(find.text('Пока нет задач'), findsNothing);
    expect(find.text('Начать заново'), findsOneWidget);
  });

  for (final width in [320.0, 800.0]) {
    testWidgets('форма и длинный текст при ширине $width', (tester) async {
      tester.view.physicalSize = Size(width, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await launch(tester);
      await openForm(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      await tester.pump();
      await tester.enterText(
        find.byType(TextField),
        'Очень длинное название задачи для проверки узкого экрана',
      );
      await tester.ensureVisible(find.text('Сохранить'));
      await tester.tap(find.text('Сохранить'));
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(
        find.text('Очень длинное название задачи для проверки узкого экрана'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await askDelete(tester, find.byType(ListTile).last);
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final dialog in [false, true]) {
    testWidgets(
      'владелец State удалён во время ${dialog ? "диалога" : "перехода"}',
      (tester) async {
        final show = ValueNotifier(true);
        addTearDown(show.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: ValueListenableBuilder<bool>(
              valueListenable: show,
              builder: (context, visible, child) =>
                  visible ? const TodoPage() : const SizedBox(),
            ),
          ),
        );
        if (dialog) {
          await askDelete(tester, find.byType(ListTile).first);
        } else {
          await openForm(tester);
          await tester.enterText(find.byType(TextField), 'Задача');
        }
        show.value = false;
        await tester.pump();
        await tester.tap(find.text(dialog ? 'Удалить' : 'Сохранить'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
