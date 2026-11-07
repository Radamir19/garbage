// После flutter pub add flutter_slidable:4.0.3.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flutter_slidable объявлен прямой runtime-зависимостью', () {
    var section = '';
    var declared = false;
    for (final line in File('pubspec.yaml').readAsLinesSync()) {
      if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
      if (!line.startsWith(' ') && !line.startsWith('\t')) {
        section = line.split(':').first.trim();
      } else if (section == 'dependencies' &&
          line.trimLeft().startsWith('flutter_slidable:')) {
        declared = true;
      }
    }
    expect(
      declared,
      isTrue,
      reason: 'Выполните flutter pub add flutter_slidable:4.0.3',
    );
  });

  test('flutter_slidable установлен и зафиксирован в lock-файле', () {
    final config =
        jsonDecode(File('.dart_tool/package_config.json').readAsStringSync())
            as Map<String, dynamic>;
    final packages = config['packages'] as List<dynamic>;
    expect(
      packages.any((p) => p['name'] == 'flutter_slidable'),
      isTrue,
      reason: 'После добавления пакета должен успешно пройти pub get',
    );
    expect(
      File('pubspec.lock').readAsStringSync(),
      matches(RegExp(r'^  flutter_slidable:', multiLine: true)),
    );
  });
}
