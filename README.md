# Finpath

A Flutter-based financial tracking application integrated with Firebase.

## Getting Started

Follow these steps to set up and run the project locally.

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
*   [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
*   Android SDK 36 (required for `path_provider_android`)
*   A Firebase project

### Setup & Execution Steps

1.  **Clone the Repository**
    ```bash
    git clone <repository-url>
    cd finpath
    ```

2.  **Add Firebase Configuration**
    *   Place your `google-services.json` file in the `android/app/` directory.
    *   *Note: This file is excluded from version control for security.*

3.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

4.  **Clean the Project** (Recommended for the first build or after configuration changes)
    ```bash
    flutter clean
    ```

5.  **Run the Application**
    ```bash
    flutter run
    ```

## Build Configuration Details

*   **Android Namespace:** `com.finpath.finpath`
*   **Compile SDK:** 36
*   **Target SDK:** 36
*   **Min SDK:** 21
*   **Gradle DSL:** Kotlin (.kts)
*   **AGP Compatibility:** Includes a custom `subprojects` block in `android/build.gradle.kts` to automatically inject namespaces into older libraries (like `isar_flutter_libs`), ensuring compatibility with Android Gradle Plugin 8.0+.

## Project Structure

*   `lib/`: Main Dart source code.
*   `android/`: Android-specific configuration and Kotlin DSL build scripts.
*   `ios/`: iOS-specific configuration.
