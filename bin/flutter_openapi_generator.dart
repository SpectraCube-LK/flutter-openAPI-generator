#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_openapi_generator/src/cli_runner.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('schema', abbr: 's', help: 'Path or URL to OpenAPI schema file')
    ..addOption('output', abbr: 'o', help: 'Output directory path')
    ..addOption('config', abbr: 'c', help: 'Configuration file path')
    ..addOption('api-url', abbr: 'u', help: 'Base API URL')
    ..addFlag('models-only', help: 'Generate only model classes')
    ..addFlag('repos-only', help: 'Generate only repository classes')
    ..addFlag('help',
        abbr: 'h', help: 'Show usage information', negatable: false);

  try {
    final results = parser.parse(arguments);

    if (results['help']) {
      print('Flutter OpenAPI Code Generator');
      print('');
      print('Usage: flutter_openapi_gen [options]');
      print('');
      print('Options:');
      print(parser.usage);
      exit(0);
    }

    final runner = CliRunner();
    final args = <String, dynamic>{
      'schema': results['schema'],
      'output': results['output'],
      'config': results['config'],
      'api-url': results['api-url'],
      'models-only': results['models-only'],
      'repos-only': results['repos-only'],
    };
    await runner.run(args);
  } catch (e) {
    print('Error: $e');
    print('');
    print('Usage: flutter_openapi_gen [options]');
    print(parser.usage);
    exit(1);
  }
}
