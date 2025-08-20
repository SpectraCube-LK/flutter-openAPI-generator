# Flutter OpenAPI 3.1.0 Code Generator

A CLI tool that generates Flutter model classes and repository classes from OpenAPI 3.1.0 JSON schema files. The tool produces clean, production-ready Dart code following Flutter best practices.

## Features

- **Model Generation**: Creates immutable Dart classes with proper null safety
- **Repository Generation**: Generates repository classes for API endpoints
- **Configuration Support**: YAML configuration file for customization
- **Flexible Input**: Supports local files and URLs for OpenAPI 3.1.0 schemas
- **Clean Code**: Generates lint-compliant, well-formatted Dart code
- **Selective Generation**: Option to generate only models or repositories
- **Package Integration**: Support for custom package names and API client imports

## Installation

1. Clone this repository
2. Install dependencies:
   ```bash
   dart pub get
   ```
3. Make the CLI executable:
   ```bash
   chmod +x bin/flutter_openapi_gen.dart
   ```

## Usage

### Basic Usage

```bash
dart run bin/flutter_openapi_gen.dart -s ./samples/api-schema.json -o ./lib/data
```

### Using Configuration File

```bash
dart run bin/flutter_openapi_gen.dart -c ./generator_config.yaml
```

### Command Line Options

- `-s, --schema`: Path or URL to OpenAPI 3.1.0 schema file
- `-o, --output`: Output directory path
- `-c, --config`: Configuration file path
- `--models-only`: Generate only model classes
- `--repos-only`: Generate only repository classes
- `--help`: Show usage information

## Configuration

Create a `generator_config.yaml` file to customize the generation:

```yaml
api:
  schema_path: "./samples/api-schema.json"
  use_global_settings: true
  package_name: "package_name"
  api_client_import: "lib/core/network/api_client.dart"
  
output:
  base_directory: "./lib/data/generated"
  models_path: "models"
  repositories_path: "repositories"
  
generation:
  add_to_json: true
  add_logging: true
  null_safety: true
  
naming:
  model_suffix: ""
  repository_suffix: "Repository"
  
features:
  generate_toString: false
  generate_copyWith: false
  generate_equality: false
```

### Configuration Options

#### API Configuration
- `schema_path`: Path to OpenAPI 3.1.0 schema file
- `use_global_settings`: Whether to use global settings from the schema
- `package_name`: Custom package name for generated code
- `api_client_import`: Import path for custom API client

#### Output Configuration
- `base_directory`: Base directory for generated files
- `models_path`: Subdirectory for model classes
- `repositories_path`: Subdirectory for repository classes

#### Generation Configuration
- `add_to_json`: Include `toJson` method in models
- `add_logging`: Add logging to repository methods
- `null_safety`: Enable null safety features
- `models_only`: Generate only model classes
- `repos_only`: Generate only repository classes

#### Naming Configuration
- `model_suffix`: Suffix for model class names
- `repository_suffix`: Suffix for repository class names

#### Features Configuration
- `generate_toString`: Generate `toString` method for models
- `generate_copyWith`: Generate `copyWith` method for models
- `generate_equality`: Generate equality methods for models

## Generated Code Structure

The tool generates the following structure:

```
output_directory/
├── models/
│   ├── user_model.dart
│   ├── post_model.dart
│   └── comment_model.dart
└── repositories/
    ├── users_repository.dart
    └── posts_repository.dart
```

## Model Classes

Generated model classes include:

- Immutable properties with `final` keyword
- Constructor with required and optional parameters
- `fromJson` factory constructor for deserialization
- `toJson` method for serialization (if enabled)
- Null safety support
- Optional `toString`, `copyWith`, and equality methods

Example generated model:

```dart
class UserModel {
  final String id;
  final String name;
  final String? email;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

## Repository Classes

Generated repository classes include:

- HTTP client integration
- Async methods returning `Future<T>`
- Proper error handling
- Request/response parsing
- Optional logging
- Custom API client import support

Example generated repository:

```dart
class UsersRepository {
  final String baseUrl;
  final http.Client _client;

  UsersRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<UserModel> getUser(String id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final request = http.Request('GET', url);
    
    try {
      final response = await _client.send(request);
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        return UserModel.fromJson(json);
      } else {
        throw Exception('HTTP GET failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }
}
```

## Data Type Mapping

The tool maps OpenAPI 3.1.0 types to Dart types:

| OpenAPI Type | Dart Type |
|--------------|-----------|
| string | String |
| integer | int |
| number | double |
| boolean | bool |
| array | List<T> |
| object | Custom class or Map<String, dynamic> |

## Requirements

- Dart SDK 3.0.0 or higher
- Flutter (for using generated code)

## License

This project is for internal use only.
