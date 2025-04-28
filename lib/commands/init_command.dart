import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:ansicolor/ansicolor.dart';

class InitCommand extends Command {
  @override
  final name = 'init';

  @override
  final description = 'Initialize a Flutter project with BLoC architecture';

  InitCommand() {
    argParser.addOption(
      'project-dir',
      abbr: 'p',
      help: 'Path to the Flutter project',
      defaultsTo: '.',
    );
  }

  @override
  Future<void> run() async {
    final projectDir = argResults?['project-dir'] as String;

    // Check if it's a Flutter project
    final pubspecFile = File(path.join(projectDir, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      printError('Cannot find pubspec.yaml. Are you in a Flutter project?');
      exit(1);
    }

    try {
      final pubspecContent = pubspecFile.readAsStringSync();
      final pubspec = loadYaml(pubspecContent);

      if (pubspec['dependencies'] == null ||
          pubspec['dependencies']['flutter'] == null) {
        printError('This does not appear to be a Flutter project.');
        exit(1);
      }

      print('🚀 Initializing BlocX in ${path.absolute(projectDir)}');

      // Add dependencies
      await addDependencies(projectDir);

      // Create folder structure
      createFolderStructure(projectDir);

      // Create basic files
      createBaseFiles(projectDir);

      printSuccess('✅ BlocX initialization complete!');
      print('\nRun "flutter pub get" to install the new dependencies.');
    } catch (e) {
      printError('Failed to initialize BlocX: $e');
      exit(1);
    }
  }

  Future<void> addDependencies(String projectDir) async {
    print('📦 Adding dependencies...');

    final pubspecFile = File(path.join(projectDir, 'pubspec.yaml'));
    final pubspecContent = pubspecFile.readAsStringSync();

    final yamlEditor = YamlEditor(pubspecContent);

    // Add dependencies
    final dependencies = {
      'bloc': '^8.1.2',
      'flutter_bloc': '^8.1.3',
      'go_router': '^10.1.2',
      'dartz': '^0.10.1',
      'get_it': '^7.6.0',
      'equatable': '^2.0.5',
    };

    for (final dep in dependencies.entries) {
      try {
        yamlEditor.update(['dependencies', dep.key], dep.value);
      } catch (_) {
        try {
          yamlEditor.appendToList(['dependencies'], {dep.key: dep.value});
        } catch (e) {
          print('Warning: Could not add dependency ${dep.key}: $e');
        }
      }
    }

    // Write modified pubspec back to file
    pubspecFile.writeAsStringSync(yamlEditor.toString());
    print('Dependencies added to pubspec.yaml');
  }

  void createFolderStructure(String projectDir) {
    print('📁 Creating folder structure...');

    final libDir = path.join(projectDir, 'lib');

    // Create main folders
    createFolder(path.join(libDir, 'core'));
    createFolder(path.join(libDir, 'features'));
    createFolder(path.join(libDir, 'routes'));
    createFolder(path.join(libDir, 'services'));
    createFolder(path.join(libDir, 'widgets'));

    // Create core subfolders
    createFolder(path.join(libDir, 'core', 'constants'));
    createFolder(path.join(libDir, 'core', 'dependency_injection'));
    createFolder(path.join(libDir, 'core', 'error'));
    createFolder(path.join(libDir, 'core', 'network'));
    createFolder(path.join(libDir, 'core', 'themes'));
    createFolder(path.join(libDir, 'core', 'utils'));
  }

  void createBaseFiles(String projectDir) {
    print('📝 Creating base files...');

    final libDir = path.join(projectDir, 'lib');

    // Create dependency injection setup
    final diFile = File(path.join(
        libDir, 'core', 'dependency_injection', 'injection_container.dart'));
    diFile.writeAsStringSync('''
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register services
  
  // Register blocs
  
  // Register repositories
  
  // Register data sources
}
''');

    // Create error handler
    final errorFile = File(path.join(libDir, 'core', 'error', 'failures.dart'));
    errorFile.writeAsStringSync('''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
''');

    // Create route configuration
    final routeFile = File(path.join(libDir, 'routes', 'app_pages.dart'));
    routeFile.writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';


final router = GoRouter(
  initialLocation: '/home',
  navigatorKey: GlobalNavigation.instance.navigatorKey,
  routes: [

  ],
);

class GlobalNavigation {
  static final GlobalNavigation instance = GlobalNavigation._internal();
  GlobalNavigation._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

''');

    // Create route configuration
    final pageFile = File(path.join(libDir, 'routes', 'app_routes.dart'));
    pageFile.writeAsStringSync('''
abstract class Routes {
  Routes._();
}

abstract class _Paths {
  _Paths._();
}

abstract class _Names {
  _Names._();
}

abstract class Names {
  Names._();
}
''');

    // Create themes setup
    final themeFile =
        File(path.join(libDir, 'core', 'themes', 'app_theme.dart'));
    themeFile.writeAsStringSync('''
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
    );
  }
}
''');

    // Update main.dart file
    final mainFile = File(path.join(libDir, 'main.dart'));
    if (mainFile.existsSync()) {
      mainFile.writeAsStringSync('''
import 'package:blocx_test/app.dart';
import 'package:flutter/material.dart';
import 'core/dependency_injection/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}
''');
    }

    // Update main.dart file
    final appFile = File(path.join(libDir, 'app.dart'));
    if (appFile.existsSync()) {
      appFile.writeAsStringSync('''
import 'package:blocx_test/core/themes/app_theme.dart';
import 'package:blocx_test/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => HomeBloc())],
      child: MaterialApp.router(
        title: 'Enter your app name',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
''');
    }
  }

  void createFolder(String path) {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }

  void printError(String message) {
    final pen = AnsiPen()..red();
    print(pen('❌ $message'));
  }

  void printSuccess(String message) {
    final pen = AnsiPen()..green();
    print(pen(message));
  }
}
