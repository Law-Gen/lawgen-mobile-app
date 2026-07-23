# LawGen: AI-Powered Legal Information Assistant 🏛️

Welcome to the official repository for **LawGen**. This document serves as the central guide for all developers working on the project, outlining our architectural approach, development methodology, and project structure.

## Table of Contents
1.  [Project Overview](#project-overview)
2.  [Architectural Design: Clean Architecture](#architectural-design-clean-architecture)
    * [Domain Layer](#domain-layer)
    * [Data Layer](#data-layer)
    * [Presentation Layer](#presentation-layer)
3.  [Development Methodology: Test-Driven Development (TDD)](#development-methodology-test-driven-development-tdd)
4.  [Project Directory Structure](#project-directory-structure)
5.  [Feature Breakdown](#feature-breakdown)
6.  [Getting Started](#getting-started)
7.  [Branching Strategy: GitFlow](#branching-strategy-gitflow)
8.  [Code Style & Linting](#code-style--linting)

---

## Project Overview

**LawGen** is a mobile application designed to provide accessible, educational legal information to users in both **English** and **Amharic**. It features an AI-powered chat interface for legal queries, a directory of legal aid providers, categorized legal summaries, and interactive quizzes. The app operates on an "Information, Not Advice" principle, empowering users to better understand their rights and legal options.

---

## Architectural Design: Clean Architecture

To ensure the application is scalable, maintainable, and testable, we are strictly adhering to the principles of **Clean Architecture**. This approach separates concerns into distinct layers, with dependencies pointing inwards towards the core business logic.



```
+-------------------------------------------------------------+
|                     Presentation Layer                      |
| (UI, State Management - BLoC/Cubit, Widgets)                |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                         Domain Layer                        |
| (Entities, Use Cases, Abstract Repositories)                |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                          Data Layer                         |
| (Repository Implementations, Data Sources - API, DB, Cache) |
+-------------------------------------------------------------+
```

### Domain Layer
* **Purpose**: This is the core of the application. It contains the enterprise business logic and is completely independent of any framework or external dependency.
* **Contents**:
    * **Entities**: Business objects representing core concepts (e.g., `User`, `Quiz`, `LegalTopic`).
    * **Use Cases (Interactors)**: Classes that orchestrate the flow of data to and from entities by invoking repositories. Each use case represents a single business action (e.g., `RegisterUser`, `GetChatHistory`, `FetchQuizById`).
    * **Repository Interfaces (Abstract)**: Defines the contracts (methods) that the Data Layer must implement. This decouples the Domain from the specifics of data retrieval.

### Data Layer
* **Purpose**: This layer is responsible for implementing the repository interfaces defined in the Domain layer. It handles all data operations, deciding whether to fetch data from a remote API, a local database, or a cache.
* **Contents**:
    * **Repository Implementations**: Concrete classes that implement the repository interfaces from the Domain layer.
    * **Data Sources**:
        * **Remote**: Handles communication with external APIs (e.g., REST, GraphQL).
        * **Local**: Manages local data persistence (e.g., SQLite, Hive, Shared Preferences for caching).
    * **Models**: Data Transfer Objects (DTOs) that are specific to the data sources (e.g., JSON parsing models). These models are mapped to/from Domain Entities within this layer.

### Presentation Layer
* **Purpose**: This layer is responsible for everything related to the UI. It presents data to the user and handles their interactions.
* **Contents**:
    * **UI (Widgets/Screens)**: The declarative UI components that the user sees and interacts with.
    * **State Management (BLoC/Cubit)**: Manages the state of the UI. It communicates with the Domain layer by executing use cases and listens for the results, updating the UI accordingly.
    * **Routing**: Handles navigation between screens.

---

## Development Methodology: Test-Driven Development (TDD) 🧪

We will be implementing the entire application using a **Test-Driven Development (TDD)** workflow. This ensures that every piece of logic is backed by a test, leading to a more robust, reliable, and maintainable codebase.

The TDD cycle (**Red-Green-Refactor**) must be followed for all new feature development:
1.  **🔴 Red**: Write a failing test that defines a new function or improvement. Run the test to ensure it fails as expected.
2.  **🟢 Green**: Write the simplest possible code to make the test pass. Do not worry about code quality at this stage.
3.  **🔵 Refactor**: Clean up the code you just wrote while keeping the tests passing. Remove duplication, improve readability, and ensure it adheres to our architectural principles.

---

## Project Directory Structure

To maintain consistency, all features will be structured as self-contained modules within the `lib/features` directory.

```
lib/
├── app/           # Global app configuration, routing, themes , dependency injection
├── core/
|   ├──errors/
|   ├──utils/
|   └──constants/
|                   # Shared utilities, error handling, constants, extensions
└── features/
    └── <feature_name>/
        ├── data/
        │   ├── datasources/  # Remote & Local data sources
        │   ├── models/       # Data transfer models (e.g., from JSON)
        │   └── repositories/ # Concrete implementation of domain repositories
        ├── domain/
        │   ├── entities/     # Core business objects
        │   ├── repositories/ # Abstract repository contracts
        │   └── usecases/     # Business logic interactors
        ├── presentation/
        │    ├── bloc/         # BLoCs or Cubits for state management
        │    ├── pages/        # The screens/pages for the feature
        │    └── widgets/      # Reusable UI components specific to th 
        |
        └──dependency/     
```

---

## Feature Breakdown

Based on the functional requirements, the app will be broken down into the following feature modules:

1.  **`onboarding_auth`**:
    * Handles onboarding screens, consent (FR1).
    * Manages user registration, login, and password recovery (FR2).

2.  **`chat`**:
    * Implements the core chat interface for both anonymous and logged-in users (FR3, FR4).
    * Handles multilingual support and voice input within the chat context (FR13, FR14).

3.  **`legal_content`**:
    * Manages the "Legal Aid Directory" (FR6).
    * Manages the "Categories by Law" and topic detail pages (FR7).
    * Includes offline access logic for cached content (FR15).

4.  **`quizzes`**:
    * Handles listing, taking, and viewing results for legal quizzes (FR8).

5.  **`profile_and_premium`**:
    * Manages user profile viewing and editing (FR9).
    * Handles the premium upgrade flow, payment integration, and subscription status (FR10, FR12).

6.  **`admin`**:
    * Contains all admin-facing functionality for managing users, quizzes, and legal content (FR16).

---

## Getting Started

Follow these steps to set up your local development environment.

### Prerequisites
* Flutter SDK (latest stable version)
* An IDE (VS Code or Android Studio)
* Git

### Installation
1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd lawgen
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Set up environment variables:**
    * Create a `.env` file in the root of the project.
    * Add the required API keys and base URLs (refer to the project's shared documentation for the keys).

4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## Branching Strategy: GitFlow

We will use the **GitFlow** branching model to manage our development lifecycle.

* `main`: Contains production-ready code. Direct pushes are forbidden.
* `develop`: The primary development branch. All feature branches are merged into `develop`.
* `feature/<feature-name>`: Branched from `develop` for new feature work (e.g., `feature/chat-history`).
* `release/<version>`: Branched from `develop` to prepare for a new production release.
* `hotfix/<issue>`: Branched from `main` to address critical production bugs.

---

## Code Style & Linting

We use the standard Dart and Flutter linters to enforce a consistent code style. Please ensure you run the formatter before committing your code.

* **Format code:**
    ```bash
    dart format .
    ```
* **Analyze code:**
    ```bash
    flutter analyze
    ```

Happy coding! 🚀