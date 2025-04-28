// File: lib/commands/feature_command.dart
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:ansicolor/ansicolor.dart';

class FeatureCommand extends Command {
  @override
  final name = 'feature';

  @override
  final description = 'Create a new feature with Clean Architecture structure';

  FeatureCommand() {
    argParser.addOption(
      'project-dir',
      abbr: 'p',
      help: 'Path to the Flutter project',
      defaultsTo: '.',
    );
  }

  @override
  Future<void> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      printError('Please provide a feature name.');
      exit(1);
    }

    final featureName = argResults!.rest[0];
    final projectDir = argResults?['project-dir'] as String;

    // Check if it's a Flutter project
    final pubspecFile = File(path.join(projectDir, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      printError('Cannot find pubspec.yaml. Are you in a Flutter project?');
      exit(1);
    }

    // Create feature folder structure and files
    createFeatureFolders(featureName, projectDir);

    try {
      // Add routes
      final pathRoute = '/$featureName';
      addRouteToAppRoutes(featureName, pathRoute, projectDir);

      final className =
          '${featureName[0].toUpperCase()}${featureName.substring(1)}Page';
      addRouteToAppPages(featureName, className, projectDir);

      printSuccess('✅ Feature $featureName has been added successfully.');
    } catch (e) {
      printWarning('Route files not updated: $e');
      printWarning('You may need to add routes manually.');
    }
  }

  /// Converts a string to snake_case
  String toSnakeCase(String input) {
    return input
        .replaceAllMapped(RegExp(r'([A-Z])'),
            (Match match) => '_${match.group(1)!.toLowerCase()}')
        .toLowerCase()
        .replaceFirst(RegExp(r'^_'), '');
  }

  void createFeatureFolders(String featureName, String projectDir) {
    final basePath = path.join(projectDir, 'lib/features/$featureName');

    // List of directories to be created based on the shown structure
    final directories = [
      '$basePath/data',
      '$basePath/data/datasources',
      '$basePath/data/models',
      '$basePath/data/repositories',
      '$basePath/domain',
      '$basePath/domain/entities',
      '$basePath/domain/repositories',
      '$basePath/domain/usecases',
      '$basePath/presentation',
      '$basePath/presentation/bloc',
      '$basePath/presentation/pages',
      '$basePath/presentation/widgets',
    ];

    for (final dir in directories) {
      final directory = Directory(dir);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
        print('Created directory: $dir');
      } else {
        printWarning('Directory already exists: $dir');
      }
    }

    // Create the page file inside the pages folder
    createPageFile(featureName, basePath);

    // Create bloc files (bloc, event, state)
    createBlocFiles(featureName, basePath);

    // Create repository files
    createRepositoryFiles(featureName, basePath);

    // Create entity file
    createEntityFile(featureName, basePath);

    // Create model file
    createModelFile(featureName, basePath);

    // Create datasource file
    createDatasourceFile(featureName, basePath);

    // Create usecases
    createUsecaseFiles(featureName, basePath);
  }

  void createPageFile(String featureName, String basePath) {
    final snakeCaseName = toSnakeCase(featureName);
    getPackageName(basePath);
    final pageFile =
        File('$basePath/presentation/pages/${snakeCaseName}_page.dart');

    if (!pageFile.existsSync()) {
      pageFile.writeAsStringSync('''
import 'package:flutter/material.dart';

class ${featureName[0].toUpperCase()}${featureName.substring(1)}Page extends StatelessWidget {
  const ${featureName[0].toUpperCase()}${featureName.substring(1)}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${featureName[0].toUpperCase()}${featureName.substring(1)}'),
      ),
      body: Center(
        child: Text('Welcome to $featureName page!'),
      ),
    );
  }
}
''');
      print('Created page file: ${snakeCaseName}_page.dart');
    }
  }

  void createBlocFiles(String featureName, String basePath) {
    final snakeCaseName = toSnakeCase(featureName);
    final blocFile =
        File('$basePath/presentation/bloc/${snakeCaseName}_bloc.dart');
    final eventFile =
        File('$basePath/presentation/bloc/${snakeCaseName}_event.dart');
    final stateFile =
        File('$basePath/presentation/bloc/${snakeCaseName}_state.dart');

    final classNamePrefix =
        featureName[0].toUpperCase() + featureName.substring(1);
    final packageName = getPackageName(basePath);

    if (!blocFile.existsSync()) {
      blocFile.writeAsStringSync('''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:$packageName/features/$featureName/presentation/bloc/${snakeCaseName}_event.dart';
import 'package:$packageName/features/$featureName/presentation/bloc/${snakeCaseName}_state.dart';

class ${classNamePrefix}Bloc extends Bloc<${classNamePrefix}Event, ${classNamePrefix}State> {
  ${classNamePrefix}Bloc() : super(${classNamePrefix}Initial()) {
    on<${classNamePrefix}Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
''');
      print('Created bloc file: ${snakeCaseName}_bloc.dart');
    }

    if (!eventFile.existsSync()) {
      eventFile.writeAsStringSync('''
import 'package:equatable/equatable.dart';

sealed class ${classNamePrefix}Event extends Equatable {
  const ${classNamePrefix}Event();

  @override
  List<Object> get props => [];
}
''');
      print('Created event file: ${snakeCaseName}_event.dart');
    }

    if (!stateFile.existsSync()) {
      stateFile.writeAsStringSync('''
import 'package:equatable/equatable.dart';

sealed class ${classNamePrefix}State extends Equatable {
  const ${classNamePrefix}State();

  @override
  List<Object> get props => [];
}

final class ${classNamePrefix}Initial extends ${classNamePrefix}State {}
''');
      print('Created state file: ${snakeCaseName}_state.dart');
    }
  }

  void createRepositoryFiles(String featureName, String basePath) {
    final snakeCaseName = toSnakeCase(featureName);
    final classNamePrefix =
        featureName[0].toUpperCase() + featureName.substring(1);
    final packageName = getPackageName(basePath);

    // Domain repository interface
    final repositoryFile =
        File('$basePath/domain/repositories/${snakeCaseName}_repository.dart');
    if (!repositoryFile.existsSync()) {
      repositoryFile.writeAsStringSync('''
import 'package:dartz/dartz.dart';
import 'package:$packageName/core/error/failures.dart';
import 'package:$packageName/features/$featureName/domain/entities/$snakeCaseName.dart';

abstract class ${classNamePrefix}Repository {
  Future<Either<Failure, $classNamePrefix>> get$classNamePrefix();
}
''');
      print('Created repository interface: ${snakeCaseName}_repository.dart');
    }

    // Data repository implementation
    final repositoryImplFile = File(
        '$basePath/data/repositories/${snakeCaseName}_repository_impl.dart');
    if (!repositoryImplFile.existsSync()) {
      repositoryImplFile.writeAsStringSync('''
import 'package:dartz/dartz.dart';
import 'package:$packageName/core/error/failures.dart';
import 'package:$packageName/features/$featureName/data/datasources/${snakeCaseName}_datasource.dart';
import 'package:$packageName/features/$featureName/domain/entities/$snakeCaseName.dart';
import 'package:$packageName/features/$featureName/domain/repositories/${snakeCaseName}_repository.dart';

class ${classNamePrefix}RepositoryImpl implements ${classNamePrefix}Repository {
  final ${classNamePrefix}Datasource datasource;

  ${classNamePrefix}RepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, $classNamePrefix>> get$classNamePrefix() async {
    try {
      final result = await datasource.get$classNamePrefix();
      return Right(result.toEntity());
    } on Exception {
      return Left(ServerFailure(message: "Something went wrong!"));
    }
  }
}
''');
      print(
          'Created repository implementation: ${snakeCaseName}_repository_impl.dart');
    }
  }

  void createEntityFile(String featureName, String basePath) {
    final snakeCaseName = toSnakeCase(featureName);
    final classNamePrefix =
        featureName[0].toUpperCase() + featureName.substring(1);

    final entityFile = File('$basePath/domain/entities/$snakeCaseName.dart');
    if (!entityFile.existsSync()) {
      entityFile.writeAsStringSync('''
import 'package:equatable/equatable.dart';

class $classNamePrefix extends Equatable {
  final String id;
  final String name;

  const $classNamePrefix({
    required this.id,
    required this.name,
  });

  @override
  List<Object> get props => [id, name];
}
''');
      print('Created entity file: $snakeCaseName.dart');
    }
  }

  void createModelFile(String featureName, String basePath) {
    final snakeCaseName = toSnakeCase(featureName);
    final classNamePrefix =
        featureName[0].toUpperCase() + featureName.substring(1);
    final packageName = getPackageName(basePath);

    final modelFile = File('$basePath/data/models/${snakeCaseName}_model.dart');
    if (!modelFile.existsSync()) {
      modelFile.writeAsStringSync('''
import 'package:$packageName/features/$featureName/domain/entities/$snakeCaseName.dart';

class ${classNamePrefix}Model {
  final String id;
  final String name;

  ${classNamePrefix}Model({
    required this.id,
    required this.name,
  });

  factory ${classNamePrefix}Model.fromJson(Map<String, dynamic> json) {
    return ${classNamePrefix}Model(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  $classNamePrefix toEntity() {
    return $classNamePrefix(
      id: id,
      name: name,
    );
  }
}
''');
      print('Created model file: ${snakeCaseName}_model.dart');
    }
  }

  void createDatasourceFile(String featureName, String basePath) {
    final snakeCaseName = toSnakeCase(featureName);
    final classNamePrefix =
        featureName[0].toUpperCase() + featureName.substring(1);
    final packageName = getPackageName(basePath);

    final datasourceFile =
        File('$basePath/data/datasources/${snakeCaseName}_datasource.dart');
    if (!datasourceFile.existsSync()) {
      datasourceFile.writeAsStringSync('''
import 'package:$packageName/features/$featureName/data/models/${snakeCaseName}_model.dart';

abstract class ${classNamePrefix}Datasource {
  Future<${classNamePrefix}Model> get$classNamePrefix();
}

class ${classNamePrefix}DatasourceImpl implements ${classNamePrefix}Datasource {
  @override
  Future<${classNamePrefix}Model> get$classNamePrefix() async {
    // TODO: implement actual data source logic
    // This is just a placeholder implementation
    return ${classNamePrefix}Model(
      id: '1',
      name: '$classNamePrefix Name',
    );
  }
}
''');
      print('Created datasource file: ${snakeCaseName}_datasource.dart');
    }
  }

  void createUsecaseFiles(String featureName, String basePath) {
    final snakeCaseName = toSnakeCase(featureName);
    final classNamePrefix =
        featureName[0].toUpperCase() + featureName.substring(1);
    final packageName = getPackageName(basePath);

    final usecaseFile =
        File('$basePath/domain/usecases/get_$snakeCaseName.dart');
    if (!usecaseFile.existsSync()) {
      usecaseFile.writeAsStringSync('''
import 'package:dartz/dartz.dart';
import 'package:$packageName/core/error/failures.dart';
import 'package:$packageName/features/$featureName/domain/entities/$snakeCaseName.dart';
import 'package:$packageName/features/$featureName/domain/repositories/${snakeCaseName}_repository.dart';

class Get$classNamePrefix {
  final ${classNamePrefix}Repository repository;

  Get$classNamePrefix(this.repository);

  Future<Either<Failure, $classNamePrefix>> call() async {
    return await repository.get$classNamePrefix();
  }
}
''');
      print('Created usecase file: get_$snakeCaseName.dart');
    }
  }

  void addRouteToAppRoutes(
      String featureName, String pathName, String projectDir) {
    final routesFile =
        File(path.join(projectDir, 'lib/routes/app_routes.dart'));

    if (!routesFile.existsSync()) {
      printWarning('app_routes.dart file not found. Skipping route addition.');
      return;
    }

    final content = routesFile.readAsStringSync();

    final routesEntry = '''
  static const $featureName = _Paths.$featureName;''';
    final pathsEntry = '''
  static const $featureName = '$pathName';''';
    final namesEntry = '''
  static const $featureName = '$featureName';''';

    final namesPathEntry = '''
  static const $featureName = _Names.$featureName;''';

    String updatedContent = content;

    if (content.contains('abstract class Routes {')) {
      updatedContent = updatedContent.replaceFirst(
        'abstract class Routes {',
        'abstract class Routes {\n$routesEntry',
      );
    }

    if (content.contains('abstract class _Paths {')) {
      updatedContent = updatedContent.replaceFirst(
        'abstract class _Paths {',
        'abstract class _Paths {\n$pathsEntry',
      );
    }

    if (content.contains('abstract class _Names {')) {
      updatedContent = updatedContent.replaceFirst(
        'abstract class _Names {',
        'abstract class _Names {\n$namesEntry',
      );
    }

    if (content.contains('abstract class Names {')) {
      updatedContent = updatedContent.replaceFirst(
        'abstract class Names {',
        'abstract class Names {\n$namesPathEntry',
      );
    }

    routesFile.writeAsStringSync(updatedContent);
    print('Updated routes in app_routes.dart');
  }

  void addRouteToAppPages(
      String featureName, String className, String projectDir) {
    final pagesFile = File(path.join(projectDir, 'lib/routes/app_pages.dart'));

    if (!pagesFile.existsSync()) {
      printWarning('app_pages.dart file not found. Skipping page addition.');
      return;
    }

    final content = pagesFile.readAsStringSync();
    final snakeCaseName = toSnakeCase(featureName);
    final packageName = getPackageName(path.join(projectDir, 'lib'));

    final importEntry =
        "import 'package:$packageName/features/$featureName/presentation/pages/${snakeCaseName}_page.dart';\n";
    final routeEntry = '''
    GoRoute(
      name: Names.$featureName,
      path: Routes.$featureName,
      builder: (context, state) => const $className(),
    ),
''';

    String updatedContent;
    if (content.contains('routes: [')) {
      updatedContent = importEntry +
          content.replaceFirst(
            'routes: [',
            'routes: [\n$routeEntry',
          );
    } else {
      updatedContent = importEntry + content;
      printWarning(
          'Could not find "routes: [" in app_pages.dart. Route might need to be added manually.');
    }

    pagesFile.writeAsStringSync(updatedContent);
    print('Updated routes in app_pages.dart');
  }

  String getPackageName(String basePath) {
    // Try to determine the package name from pubspec.yaml
    final projectDir = basePath.split('lib')[0];
    final pubspecFile = File(path.join(projectDir, 'pubspec.yaml'));

    try {
      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();
        final nameRegex = RegExp(r'name:\s+([^\s]+)');
        final match = nameRegex.firstMatch(content);
        if (match != null && match.groupCount >= 1) {
          return match.group(1)!;
        }
      }
    } catch (e) {
      // Fallback if unable to determine package name
    }

    // Default fallback
    return 'app';
  }

  void printError(String message) {
    final pen = AnsiPen()..red();
    print(pen('❌ $message'));
  }

  void printSuccess(String message) {
    final pen = AnsiPen()..green();
    print(pen(message));
  }

  void printWarning(String message) {
    final pen = AnsiPen()..yellow();
    print(pen('⚠️ $message'));
  }
}
