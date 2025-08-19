import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_openapi_generator/src/config/generator_config.dart';

class ConfigManager {
  Future<GeneratorConfig> loadConfig(Map<String, dynamic> args) async {
    GeneratorConfig config = GeneratorConfig.defaults();

    // Load from config file if provided
    if (args['config'] != null) {
      final configFile = File(args['config']);
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        final yaml = loadYaml(content);
        config = _parseYamlConfig(yaml);
      }
    }

    // Override with command line arguments
    if (args['schema'] != null) {
      config.schemaPath = args['schema'];
    }

    if (args['output'] != null) {
      config.output.baseDirectory = args['output'];
    }

    if (args['models-only'] == true) {
      config.generation.modelsOnly = true;
      config.generation.reposOnly = false;
    }

    if (args['repos-only'] == true) {
      config.generation.reposOnly = true;
      config.generation.modelsOnly = false;
    }

    // Validate configuration
    _validateConfig(config);

    return config;
  }

  GeneratorConfig _parseYamlConfig(dynamic yaml) {
    final config = GeneratorConfig.defaults();

    if (yaml['api'] != null) {
      final api = yaml['api'];
      if (api['schema_path'] != null) config.schemaPath = api['schema_path'];
      if (api['use_global_settings'] != null)
        config.api.useGlobalSettings = api['use_global_settings'];
      if (api['package_name'] != null)
        config.api.packageName = api['package_name'];
      if (api['api_client_import'] != null)
        config.api.apiClientImport = api['api_client_import'];
    }

    if (yaml['output'] != null) {
      final output = yaml['output'];
      if (output['base_directory'] != null)
        config.output.baseDirectory = output['base_directory'];
      if (output['models_path'] != null)
        config.output.modelsPath = output['models_path'];
      if (output['repositories_path'] != null)
        config.output.repositoriesPath = output['repositories_path'];
    }

    if (yaml['generation'] != null) {
      final generation = yaml['generation'];
      if (generation['add_to_json'] != null)
        config.generation.addToJson = generation['add_to_json'];
      if (generation['add_logging'] != null)
        config.generation.addLogging = generation['add_logging'];
      if (generation['null_safety'] != null)
        config.generation.nullSafety = generation['null_safety'];
    }

    if (yaml['naming'] != null) {
      final naming = yaml['naming'];
      if (naming['model_suffix'] != null)
        config.naming.modelSuffix = naming['model_suffix'];
      if (naming['repository_suffix'] != null)
        config.naming.repositorySuffix = naming['repository_suffix'];
    }

    if (yaml['features'] != null) {
      final features = yaml['features'];
      if (features['generate_toString'] != null)
        config.features.generateToString = features['generate_toString'];
      if (features['generate_copyWith'] != null)
        config.features.generateCopyWith = features['generate_copyWith'];
      if (features['generate_equality'] != null)
        config.features.generateEquality = features['generate_equality'];
    }

    return config;
  }

  void _validateConfig(GeneratorConfig config) {
    if (config.schemaPath.isEmpty) {
      throw ArgumentError('Schema path is required');
    }

    if (config.output.baseDirectory.isEmpty) {
      throw ArgumentError('Output directory is required');
    }
  }
}
