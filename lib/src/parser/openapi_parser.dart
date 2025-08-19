import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_openapi_generator/src/models/openapi_schema.dart';
import 'package:flutter_openapi_generator/src/models/model_definition.dart';
import 'package:flutter_openapi_generator/src/models/endpoint_definition.dart';

class OpenApiParser {
  Future<OpenApiSchema> parseSchema(String schemaPath) async {
    final json = await _loadSchema(schemaPath);
    return _parseJsonSchema(json);
  }

  Future<Map<String, dynamic>> _loadSchema(String schemaPath) async {
    if (schemaPath.startsWith('http://') || schemaPath.startsWith('https://')) {
      final response = await http.get(Uri.parse(schemaPath));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load schema from URL: ${response.statusCode}');
      }
    } else {
      final file = File(schemaPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content);
      } else {
        throw Exception('Schema file not found: $schemaPath');
      }
    }
  }

  OpenApiSchema _parseJsonSchema(Map<String, dynamic> json) {
    final models = <ModelDefinition>[];
    final endpoints = <EndpointDefinition>[];

    // Parse models from components/schemas
    if (json['components'] != null && json['components']['schemas'] != null) {
      final schemas = json['components']['schemas'] as Map<String, dynamic>;
      for (final entry in schemas.entries) {
        try {
          final model = _parseModelDefinition(entry.key, entry.value);
          if (model != null) {
            models.add(model);
          }
        } catch (e) {
          print('Warning: Failed to parse model ${entry.key}: $e');
        }
      }
    }

    // Parse endpoints from paths
    if (json['paths'] != null) {
      final paths = json['paths'] as Map<String, dynamic>;
      for (final pathEntry in paths.entries) {
        final path = pathEntry.key;
        final pathMethods = pathEntry.value as Map<String, dynamic>;

        for (final methodEntry in pathMethods.entries) {
          final method = methodEntry.key.toUpperCase();
          final operation = methodEntry.value as Map<String, dynamic>;

          try {
            final endpoint = _parseEndpointDefinition(path, method, operation);
            if (endpoint != null) {
              endpoints.add(endpoint);
            }
          } catch (e) {
            print('Warning: Failed to parse endpoint $method $path: $e');
          }
        }
      }
    }

    return OpenApiSchema(models: models, endpoints: endpoints);
  }

  ModelDefinition? _parseModelDefinition(
      String name, Map<String, dynamic> schema) {
    if (schema['type'] == 'object' || schema['properties'] != null) {
      final properties = <ModelProperty>[];
      final required = <String>[];

      if (schema['required'] != null) {
        required.addAll((schema['required'] as List).cast<String>());
      }

      if (schema['properties'] != null) {
        final props = schema['properties'] as Map<String, dynamic>;
        for (final propEntry in props.entries) {
          final propName = propEntry.key;
          final propSchema = propEntry.value as Map<String, dynamic>;
          final isRequired = required.contains(propName);

          final property = _parseProperty(propName, propSchema, isRequired);
          if (property != null) {
            properties.add(property);
          }
        }
      }

      return ModelDefinition(
        name: name,
        properties: properties,
        description: schema['description'] ?? '',
      );
    }

    return null;
  }

  ModelProperty? _parseProperty(
      String name, Map<String, dynamic> schema, bool isRequired) {
    String type;
    if (schema.containsKey('\$ref')) {
      final ref = schema['\$ref'] as String;
      type = _resolveRefType(ref);
    } else {
      type = _getDartType(schema);
    }
    final isNullable =
        !isRequired && (schema['nullable'] == true || type.endsWith('?'));

    return ModelProperty(
      name: name,
      type: isNullable ? '$type?' : type,
      isRequired: isRequired,
      description: schema['description'] ?? '',
    );
  }

  String _getDartType(Map<String, dynamic> schema) {
    final type = schema['type'] as String?;
    final format = schema['format'] as String?;

    switch (type) {
      case 'string':
        if (format == 'date-time') return 'DateTime';
        if (format == 'date') return 'DateTime';
        if (format == 'email') return 'String';
        if (schema['enum'] != null) return 'String';
        return 'String';
      case 'integer':
        if (format == 'int64') return 'int';
        return 'int';
      case 'number':
        if (format == 'float') return 'double';
        return 'double';
      case 'boolean':
        return 'bool';
      case 'array':
        final items = schema['items'] as Map<String, dynamic>?;
        if (items != null) {
          String itemType;
          if (items.containsKey('\$ref')) {
            final ref = items['\$ref'] as String;
            itemType = _resolveRefType(ref);
          } else {
            itemType = _getDartType(items);
          }
          return 'List<$itemType>';
        }
        return 'List<dynamic>';
      case 'object':
        if (schema['additionalProperties'] != null) {
          final additionalProps =
              schema['additionalProperties'] as Map<String, dynamic>?;
          if (additionalProps != null) {
            final valueType = _getDartType(additionalProps);
            return 'Map<String, $valueType>';
          }
        }
        return 'Map<String, dynamic>';
      default:
        return 'dynamic';
    }
  }

  EndpointDefinition? _parseEndpointDefinition(
      String path, String method, Map<String, dynamic> operation) {
    final operationId = operation['operationId'] as String?;
    final summary = operation['summary'] as String? ?? '';
    final description = operation['description'] as String? ?? '';
    final tags = <String>[];

    if (operation['tags'] != null) {
      final tagsList = operation['tags'] as List;
      for (final tag in tagsList) {
        if (tag is String) {
          tags.add(tag);
        }
      }
    }

    final parameters = <ParameterDefinition>[];
    if (operation['parameters'] != null) {
      final params = operation['parameters'] as List;
      for (final param in params) {
        final parameter = _parseParameter(param as Map<String, dynamic>);
        if (parameter != null) {
          parameters.add(parameter);
        }
      }
    }

    final requestBody =
        _parseRequestBody(operation['requestBody'] as Map<String, dynamic>?);
    final responses =
        _parseResponses(operation['responses'] as Map<String, dynamic>?);

    return EndpointDefinition(
      path: path,
      method: method,
      operationId: operationId,
      summary: summary,
      description: description,
      tags: tags,
      parameters: parameters,
      requestBody: requestBody,
      responses: responses,
    );
  }

  ParameterDefinition? _parseParameter(Map<String, dynamic> param) {
    final name = param['name'] as String?;
    final in_ = param['in'] as String?;
    final required = param['required'] as bool? ?? false;
    final schema = param['schema'] as Map<String, dynamic>?;

    if (name != null && in_ != null && schema != null) {
      String type;
      if (schema.containsKey('\$ref')) {
        final ref = schema['\$ref'] as String;
        type = _resolveRefType(ref);
      } else {
        type = _getDartType(schema);
      }
      return ParameterDefinition(
        name: name,
        location: in_,
        type: required ? type : '$type?',
        isRequired: required,
      );
    }

    return null;
  }

  RequestBodyDefinition? _parseRequestBody(Map<String, dynamic>? requestBody) {
    if (requestBody == null) return null;

    final content = requestBody['content'] as Map<String, dynamic>?;
    if (content != null && content['application/json'] != null) {
      final jsonContent = content['application/json'] as Map<String, dynamic>;
      final schema = jsonContent['schema'] as Map<String, dynamic>?;

      if (schema != null) {
        String type;
        if (schema.containsKey('\$ref')) {
          final ref = schema['\$ref'] as String;
          type = _resolveRefType(ref);
        } else {
          type = _getDartType(schema);
        }
        return RequestBodyDefinition(type: type);
      }
    }

    return null;
  }

  Map<String, ResponseDefinition> _parseResponses(
      Map<String, dynamic>? responses) {
    final result = <String, ResponseDefinition>{};

    if (responses != null) {
      for (final entry in responses.entries) {
        final statusCode = entry.key;
        final response = entry.value as Map<String, dynamic>;

        // Handle $ref responses
        if (response.containsKey('\$ref')) {
          final ref = response['\$ref'] as String;
          final type = _resolveRefType(ref);
          result[statusCode] = ResponseDefinition(
            statusCode: statusCode,
            type: type,
            description: response['description'] as String? ?? '',
          );
          continue;
        }

        final content = response['content'] as Map<String, dynamic>?;

        String? type;
        if (content != null && content['application/json'] != null) {
          final jsonContent =
              content['application/json'] as Map<String, dynamic>;
          final schema = jsonContent['schema'] as Map<String, dynamic>?;

          if (schema != null) {
            if (schema.containsKey('\$ref')) {
              final ref = schema['\$ref'] as String;
              type = _resolveRefType(ref);
            } else {
              type = _getDartType(schema);
            }
          }
        }

        result[statusCode] = ResponseDefinition(
          statusCode: statusCode,
          type: type ?? 'dynamic',
          description: response['description'] as String? ?? '',
        );
      }
    }

    return result;
  }

  String _resolveRefType(String ref) {
    if (ref.startsWith('#/components/schemas/')) {
      final schemaName = ref.substring('#/components/schemas/'.length);
      return schemaName;
    }
    return 'dynamic';
  }
}
