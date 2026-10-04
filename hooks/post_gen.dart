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

  // Uncomment the template assets block and point it at assets/images/
  // before build_runner, so flutter_gen can generate asset code.
  final assetRegistration = registerProjectAssets(pubspecContent);
  pubspecContent = assetRegistration.content;
  switch (assetRegistration.status) {
    case AssetRegistration.uncommented:
      context.logger.success(
        '✅ Uncommented assets and pointed them at assets/images/.',
      );
      break;
    case AssetRegistration.inserted:
      context.logger.success('✅ assets/images/ added under the flutter: block.');
      break;
    case AssetRegistration.exists:
      context.logger.info('ℹ️  assets/images/ is already registered.');
      break;
    case AssetRegistration.missing:
      context.logger.err(
        '❌ Could not find an assets section or flutter: block to update.',
      );
      break;
  }

  await pubspecFile.writeAsString(pubspecContent);

  final assetsDir = Directory('assets/images');
  if (!await assetsDir.exists()) {
    await assetsDir.create(recursive: true);
    context.logger.info('✅ Created assets/images/.');
  }

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

enum AssetRegistration { uncommented, inserted, exists, missing }

class AssetRegistrationResult {
  const AssetRegistrationResult(this.content, this.status);

  final String content;
  final AssetRegistration status;
}

/// Points `pubspec.yaml` at `assets/images/` before `build_runner` runs.
///
/// Flutter's default template leaves the assets block commented out. This
/// uncomments that block when it is present, otherwise inserts one under the
/// `flutter:` section.
AssetRegistrationResult registerProjectAssets(String content) {
  final activeImages = RegExp(
    r'^[ \t]*-[ \t]*assets/images/?[ \t]*$',
    multiLine: true,
  );
  if (activeImages.hasMatch(content)) {
    return AssetRegistrationResult(content, AssetRegistration.exists);
  }

  const assetBlock = '  assets:\n    - assets/images/\n';

  // Default Flutter template:
  //   # assets:
  //   #   - images/a_dot_burr.jpeg
  //   #   - images/a_dot_ham.jpeg
  final commentedAssets = RegExp(
    r'^[ \t]*#[ \t]*assets:[ \t]*\r?\n(?:[ \t]*#[ \t]*-[ \t]*\S[^\r\n]*\r?\n)*',
    multiLine: true,
  );
  if (commentedAssets.hasMatch(content)) {
    return AssetRegistrationResult(
      content.replaceFirst(commentedAssets, assetBlock),
      AssetRegistration.uncommented,
    );
  }

  final assetsHeader = RegExp(r'^[ \t]*assets:[ \t]*$', multiLine: true);
  final headerMatch = assetsHeader.firstMatch(content);
  if (headerMatch != null) {
    return AssetRegistrationResult(
      content.replaceRange(
        headerMatch.end,
        headerMatch.end,
        '\n    - assets/images/',
      ),
      AssetRegistration.inserted,
    );
  }

  final materialDesign = RegExp(
    r'^([ \t]*uses-material-design:[ \t]*true[ \t]*\r?\n)',
    multiLine: true,
  );
  if (materialDesign.hasMatch(content)) {
    return AssetRegistrationResult(
      content.replaceFirstMapped(
        materialDesign,
        (match) => '${match.group(1)}\n$assetBlock',
      ),
      AssetRegistration.inserted,
    );
  }

  return AssetRegistrationResult(content, AssetRegistration.missing);
}
