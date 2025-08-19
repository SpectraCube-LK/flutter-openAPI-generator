import 'dart:io';
import 'package:flutter_openapi_generator/src/config/config_manager.dart';
import 'package:flutter_openapi_generator/src/generator/code_generator.dart';
import 'package:flutter_openapi_generator/src/parser/openapi_parser.dart';

class CliRunner {
  final ConfigManager _configManager = ConfigManager();
  final OpenApiParser _parser = OpenApiParser();
  final CodeGenerator _generator = CodeGenerator();

  Future<void> run(Map<String, dynamic> args) async {
    try {
      // Load configuration
      final config = await _configManager.loadConfig(args);

      print('Flutter OpenAPI Code Generator');
      print('==============================');
      print('Schema: ${config.schemaPath}');
      print('Output: ${config.output.baseDirectory}');
      print('');

      // Parse OpenAPI schema
      print('Parsing OpenAPI schema...');
      final schema = await _parser.parseSchema(config.schemaPath);
      print('✓ Schema parsed successfully');
      print('  - Models: ${schema.models.length}');
      print('  - Endpoints: ${schema.endpoints.length}');
      print('');

      // Generate code
      print('Generating code...');

      if (!config.generation.reposOnly) {
        print('Generating models...');
        await _generator.generateModels(schema.models, config);
        print('✓ Models generated');
      }

      if (!config.generation.modelsOnly) {
        print('Generating repositories...');
        await _generator.generateRepositories(schema.endpoints, config);
        print('✓ Repositories generated');
      }

      print('');
      print('Code generation completed successfully!');
      print('Output directory: ${config.output.baseDirectory}');
    } catch (e) {
      print('Error during code generation: $e');
      rethrow;
    }
  }
}
