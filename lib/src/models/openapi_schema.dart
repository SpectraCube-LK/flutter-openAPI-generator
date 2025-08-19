import 'package:flutter_openapi_generator/src/models/model_definition.dart';
import 'package:flutter_openapi_generator/src/models/endpoint_definition.dart';

class OpenApiSchema {
  final List<ModelDefinition> models;
  final List<EndpointDefinition> endpoints;

  OpenApiSchema({
    required this.models,
    required this.endpoints,
  });
}
