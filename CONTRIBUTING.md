# Contributing to StudyBuddy

First off, thank you for considering contributing to StudyBuddy! It's people like you that make StudyBuddy such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead and why**
* **Include screenshots or animated GIFs** if possible
* **Include your Flutter version, device/emulator info, and OS**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior** and **explain which behavior you expected to see instead**
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Do not include issue numbers in the PR title
* Follow the Dart/Flutter style guide
* Include screenshots and animated GIFs in your pull request whenever possible
* End all files with a newline
* Write meaningful commit messages

## Development Process

1. **Fork the repo** and create your branch from `main`
2. **Install dependencies**: `flutter pub get`
3. **Make your changes**
4. **Test your changes**: `flutter test`
5. **Ensure the code is formatted**: `flutter format .`
6. **Commit your changes** with a descriptive commit message
7. **Push to your fork** and submit a pull request

## Coding Style

### Dart/Flutter Style Guide

* Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
* Use `flutter format` before committing
* Maximum line length: 80 characters (for readability)
* Use meaningful variable and function names
* Add comments for complex logic

### File Structure

```dart
// Import structure
import 'package:flutter/material.dart';  // Flutter packages
import 'package:firebase_auth/firebase_auth.dart';  // Third-party packages

import '../models/task_model.dart';  // Local imports
import '../services/task_service.dart';

// Class structure
class MyWidget extends StatefulWidget {
  // Constructor
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // State variables
  
  // Lifecycle methods
  
  // Helper methods
  
  // Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Commit Message Guidelines

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

Examples:
```
feat: Add YouTube search integration
fix: Resolve task completion celebration bug
docs: Update README with new features
style: Format code with dartfmt
refactor: Simplify task filtering logic
test: Add tests for TaskService
chore: Update dependencies
```

## Testing

* Write unit tests for new features
* Ensure all tests pass before submitting PR
* Run tests with: `flutter test`
* Test on both Android and iOS if possible

## Documentation

* Update README.md if you change functionality
* Comment your code where necessary
* Update inline documentation for public APIs
* Add dartdoc comments for classes and methods

## Getting Help

If you need help, you can:

* Open an issue with the `question` label
* Reach out to the maintainers
* Check existing documentation and issues

## Recognition

Contributors will be recognized in:
* The project README
* Release notes
* Contributors page (if applicable)

Thank you for contributing! 🎉
