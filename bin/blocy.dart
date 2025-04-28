import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:blocy/blocy.dart';

void main(List<String> arguments) {
  final runner = CommandRunner('blocx', 'Flutter BLoC architecture setup tool')
    ..addCommand(InitCommand())
    ..addCommand(FeatureCommand());

  runner.run(arguments).catchError((error) {
    if (error is! UsageException) {
      print('Error: $error');
    }
    exit(64);
  });
}
