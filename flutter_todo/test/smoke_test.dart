import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_navigation_task/main.dart';

void main() {
  testWidgets('шаблон запускается до заполнения TODO', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TodoPage()));
    expect(find.byType(TodoPage), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
