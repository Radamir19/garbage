import 'dart:io';
import 'package:flutter/services.dart';

// В тестах Flutter по умолчанию использует шрифт Ahem с квадратными
// символами. Загружаем штатные шрифты SDK, чтобы размеры были реалистичны.
Future<void> loadTestFonts() async {
  final sdk = Platform.environment['FLUTTER_ROOT'];
  final artifacts = sdk == null
      ? File(Platform.resolvedExecutable).parent.parent.parent.path
      : '$sdk/bin/cache/artifacts';
  for (final entry in {
    'Roboto': 'Roboto-Regular.ttf',
    'MaterialIcons': 'MaterialIcons-Regular.otf',
  }.entries) {
    final loader = FontLoader(entry.key);
    final bytes = await File(
      '$artifacts/material_fonts/${entry.value}',
    ).readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
}
