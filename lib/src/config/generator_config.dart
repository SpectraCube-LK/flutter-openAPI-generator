class GeneratorConfig {
  String schemaPath;
  ApiConfig api;
  OutputConfig output;
  GenerationConfig generation;
  NamingConfig naming;
  FeaturesConfig features;

  GeneratorConfig({
    required this.schemaPath,
    required this.api,
    required this.output,
    required this.generation,
    required this.naming,
    required this.features,
  });

  factory GeneratorConfig.defaults() {
    return GeneratorConfig(
      schemaPath: '',
      api: ApiConfig.defaults(),
      output: OutputConfig.defaults(),
      generation: GenerationConfig.defaults(),
      naming: NamingConfig.defaults(),
      features: FeaturesConfig.defaults(),
    );
  }
}

class ApiConfig {
  bool useGlobalSettings;
  String? packageName;
  String apiClientImport;

  ApiConfig({
    this.useGlobalSettings = false,
    this.packageName,
    this.apiClientImport = 'base_service.dart',
  });

  factory ApiConfig.defaults() {
    return ApiConfig(
      useGlobalSettings: false,
      packageName: null,
      apiClientImport: 'base_service.dart',
    );
  }
}

class OutputConfig {
  String baseDirectory;
  String modelsPath;
  String repositoriesPath;

  OutputConfig({
    required this.baseDirectory,
    required this.modelsPath,
    required this.repositoriesPath,
  });

  factory OutputConfig.defaults() {
    return OutputConfig(
      baseDirectory: './lib/data',
      modelsPath: 'models',
      repositoriesPath: 'repositories',
    );
  }
}

class GenerationConfig {
  bool addToJson;
  bool addLogging;
  bool nullSafety;
  bool modelsOnly;
  bool reposOnly;

  GenerationConfig({
    required this.addToJson,
    required this.addLogging,
    required this.nullSafety,
    required this.modelsOnly,
    required this.reposOnly,
  });

  factory GenerationConfig.defaults() {
    return GenerationConfig(
      addToJson: true,
      addLogging: true,
      nullSafety: true,
      modelsOnly: false,
      reposOnly: false,
    );
  }
}

class NamingConfig {
  String modelSuffix;
  String repositorySuffix;

  NamingConfig({
    required this.modelSuffix,
    required this.repositorySuffix,
  });

  factory NamingConfig.defaults() {
    return NamingConfig(
      modelSuffix: '',
      repositorySuffix: 'Repository',
    );
  }
}

class FeaturesConfig {
  bool generateToString;
  bool generateCopyWith;
  bool generateEquality;

  FeaturesConfig({
    required this.generateToString,
    required this.generateCopyWith,
    required this.generateEquality,
  });

  factory FeaturesConfig.defaults() {
    return FeaturesConfig(
      generateToString: false,
      generateCopyWith: false,
      generateEquality: false,
    );
  }
}
