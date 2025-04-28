# BlocY CLI

Build Flutter apps faster with a CLI tool that applies BLoC and clean architecture for scalable, maintainable projects.

## Features

- 🚀 Rapidly initialize new or existing Flutter projects with BLoC architecture
- 📁 Create consistent folder structure following clean architecture principles
- ✨ Generate feature modules with all necessary components
- 🧩 Automatically set up routing configuration using go_router
- 🛠️ Add all required dependencies

## Installation

```bash
dart pub global activate blocy
```

## Commands

### Initialize a project

Convert an existing Flutter project to use BLoC architecture with a clean, organized structure:

```bash
blocy init
```

Options:

- `--project-dir, -p`: Path to the Flutter project (default: current directory)

### Create a new feature

Generate a new feature with all necessary layers (presentation, domain, data):

```bash
blocy feature <feature_name>
```

Options:

- `--project-dir, -p`: Path to the Flutter project (default: current directory)

## Folder Structure

The tool creates the following structure for your Flutter project:

```
lib/
├── core/
│   ├── constants/
│   ├── dependency_injection/
│   ├── error/
│   ├── network/
│   ├── themes/
│   └── utils/
├── features/
│   └── home/      # Default feature
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
├── routes/
├── services/
└── widgets/
```

Each feature follows Clean Architecture principles with separate layers:

- **Presentation Layer**: UI components, BLoC classes, pages, and widgets
- **Domain Layer**: Business logic, entities, interfaces for repositories, and use cases
- **Data Layer**: Data sources, models and repository implementations

## Generated Files For Each Feature

When you create a new feature, BlocY generates:

### Presentation Layer

- BLoC, Event, and State files
- Feature page with basic UI

### Domain Layer

- Entity class
- Repository interface
- Use case implementation

### Data Layer

- API data source (with implementation)
- Data model with JSON serialization
- Repository implementation

## Dependencies

BlocY CLI automatically adds these dependencies to your project:

- `bloc`: ^8.1.2
- `flutter_bloc`: ^8.1.3
- `go_router`: ^10.1.2
- `dartz`: ^0.10.1
- `get_it`: ^7.6.0
- `equatable`: ^2.0.5

## Example Usage

### Initialize a project and create a feature

```bash
# Initialize the project in the current directory
blocy init

# Create a new feature called "authentication"
blocy feature authentication
```

### Working with the generated code

After creating a feature, you'll have a fully functional architecture to work with:

1. Add your business logic to the use cases
2. Implement the data sources with actual API calls
3. Update the UI in the pages and widgets
4. Add events and states to the BLoC classes
5. Update the DI container to register your dependencies

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues page](https://github.com/joysarkar18/blocy/issues).

## License

This project is [MIT](LICENSE) licensed.
