import 'dart:io';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final dependencies = [
    'http',
    'dio',
    'internet_connection_checker',
    'shared_preferences',
    'flutter_secure_storage',
    'jwt_decode',
    'google_fonts',
    'font_awesome_flutter',
    'ionicons',
    'intl',
    'image_picker',
    'file_picker',
    'flutter_svg',
    'awesome_dialog',
    'get_it',
    'flutter_native_splash',
    'flutter_launcher_icons',
  ];

  final devDependencies = [
    'flutter_gen_runner',
    'build_runner',
  ];

  context.logger.info('📦 Adding dependencies...');

  final commands = [
    ...dependencies.map((pkg) => ['pub', 'add', pkg]),
    ...devDependencies.map((pkg) => ['pub', 'add', '--dev', pkg]),
  ];

  for (final cmd in commands) {
    final result = await Process.run('flutter', cmd);
    if (result.exitCode != 0) {
      context.logger.err('❌ Failed to add ${cmd.last}');
      context.logger.err(result.stderr);
    } else {
      context.logger.info('✅ Added ${cmd.last}');
    }
  }

  final pubspecFile = File('pubspec.yaml');

  if (!await pubspecFile.exists()) {
    context.logger.err('❌ pubspec.yaml not found.');
    return;
  }

  var pubspecContent = await pubspecFile.readAsString();

  final flutterGenBlock = '''
flutter_gen:
  output: lib/core/gen/
  line_length: 80

  integrations:
    image: true
    flutter_svg: true
    rive: true
    lottie: true
''';

// Add flutter_gen if it doesn't already exist
  if (!pubspecContent.contains('flutter_gen:')) {
    pubspecContent += '\n$flutterGenBlock';
    context.logger.info('✅ Added flutter_gen config.');
  } else {
    context.logger.info('📄 flutter_gen already exists.');
  }

// Find the correct flutter: block (not the one under dependencies)
  final lines = pubspecContent.split('\n');
  final buffer = StringBuffer();
  bool insideFlutterBlock = false;
  bool assetAdded = false;
  bool correctFlutterBlockFound = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Detect the correct flutter: section (not under dependencies)
    if (line.trim() == 'flutter:') {
      // Check previous lines to avoid the one under dependencies
      bool isCorrect = true;
      for (int j = i - 1; j >= 0 && j >= i - 3; j--) {
        if (lines[j].contains('dependencies:')) {
          isCorrect = false;
          break;
        }
      }

      if (isCorrect) {
        insideFlutterBlock = true;
        correctFlutterBlockFound = true;
      } else {
        insideFlutterBlock = false;
      }
    }

    // If already inside the correct flutter: block
    if (insideFlutterBlock &&
        !assetAdded &&
        (line.trim().startsWith('fonts:') ||
            line.trim().isEmpty ||
            i == lines.length - 1)) {
      // Check if assets already present
      final existingAssets = lines
          .any((l) => l.trim() == 'assets:' || l.contains('- assets/images/'));
      if (!existingAssets) {
        buffer.writeln('  assets:');
        buffer.writeln('    - assets/images/');
        assetAdded = true;
      }
    }

    buffer.writeln(line);
  }

// Update content
  if (correctFlutterBlockFound && assetAdded) {
    await pubspecFile.writeAsString(buffer.toString());
    context.logger.success('✅ assets/images/ added under flutter: block.');
  } else if (!correctFlutterBlockFound) {
    context.logger.err('❌ Could not find the correct flutter: block.');
  } else {
    context.logger.info('ℹ️  assets/images/ already exists.');
  }

// Write back updated pubspec
  await pubspecFile.writeAsString(pubspecContent);

  // Run build_runner
  context.logger.info('🚧 Running build_runner...');
  final buildResult =
      await Process.run('dart', ['run', 'build_runner', 'build', '-d']);

  if (buildResult.exitCode == 0) {
    context.logger.success('✅ build_runner completed successfully.');
  } else {
    context.logger.err('❌ build_runner failed:');
    context.logger.err(buildResult.stderr);
  }

  context.logger.success('🎯 Project setup complete.');
}
