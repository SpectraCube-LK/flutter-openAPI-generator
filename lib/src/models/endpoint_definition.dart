class EndpointDefinition {
  final String path;
  final String method;
  final String? operationId;
  final String summary;
  final String description;
  final List<String> tags;
  final List<ParameterDefinition> parameters;
  final RequestBodyDefinition? requestBody;
  final Map<String, ResponseDefinition> responses;

  EndpointDefinition({
    required this.path,
    required this.method,
    this.operationId,
    required this.summary,
    required this.description,
    required this.tags,
    required this.parameters,
    this.requestBody,
    required this.responses,
  });
}

class ParameterDefinition {
  final String name;
  final String location; // path, query, header, cookie
  final String type;
  final bool isRequired;

  ParameterDefinition({
    required this.name,
    required this.location,
    required this.type,
    required this.isRequired,
  });
}

class RequestBodyDefinition {
  final String type;

  RequestBodyDefinition({
    required this.type,
  });
}

class ResponseDefinition {
  final String statusCode;
  final String type;
  final String description;

  ResponseDefinition({
    required this.statusCode,
    required this.type,
    required this.description,
  });
}
