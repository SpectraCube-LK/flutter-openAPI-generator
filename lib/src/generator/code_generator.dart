import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_openapi_generator/src/config/generator_config.dart';
import 'package:flutter_openapi_generator/src/models/model_definition.dart';
import 'package:flutter_openapi_generator/src/models/endpoint_definition.dart';
import 'package:flutter_openapi_generator/src/generator/model_generator.dart';
import 'package:flutter_openapi_generator/src/generator/repository_generator.dart';

class CodeGenerator {
  final ModelGenerator _modelGenerator = ModelGenerator();
  final RepositoryGenerator _repositoryGenerator = RepositoryGenerator();

  Future<void> generateModels(
      List<ModelDefinition> models, GeneratorConfig config) async {
    final modelsDir = Directory(
        path.join(config.output.baseDirectory, config.output.modelsPath));
    await modelsDir.create(recursive: true);

    for (final model in models) {
      final fileName = _toSnakeCase(model.name);
      final filePath = path.join(modelsDir.path, '${fileName}.dart');

      final code = _modelGenerator.generateModel(model, config);
      await File(filePath).writeAsString(code);
    }
  }

  Future<void> generateRepositories(
      List<EndpointDefinition> endpoints, GeneratorConfig config) async {
    final reposDir = Directory(
        path.join(config.output.baseDirectory, config.output.repositoriesPath));
    await reposDir.create(recursive: true);

    // Group endpoints by tags or common path prefixes
    final groupedEndpoints = _groupEndpoints(endpoints);

    for (final entry in groupedEndpoints.entries) {
      final groupName = entry.key;
      final groupEndpoints = entry.value;

      final fileName = _toSnakeCase(groupName);
      final filePath = path.join(reposDir.path, '${fileName}_repository.dart');

      final code = _repositoryGenerator.generateRepository(
        groupName,
        groupEndpoints,
        config,
      );
      await File(filePath).writeAsString(code);
    }
  }

  Map<String, List<EndpointDefinition>> _groupEndpoints(
      List<EndpointDefinition> endpoints) {
    final groups = <String, List<EndpointDefinition>>{};

    for (final endpoint in endpoints) {
      String groupName = 'api';

      // Try to group by tags first
      if (endpoint.tags.isNotEmpty) {
        groupName = endpoint.tags.first.toLowerCase();
      } else {
        // Group by path prefix
        final pathParts =
            endpoint.path.split('/').where((part) => part.isNotEmpty).toList();
        if (pathParts.isNotEmpty) {
          groupName = pathParts.first;
        }
      }

      groups.putIfAbsent(groupName, () => []).add(endpoint);
    }

    return groups;
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_'), '');
  }
}
