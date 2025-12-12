# Autocomplete Dropdown App

A Flutter application demonstrating a reusable autocomplete dropdown widget.

## Features

- **Autocomplete Dropdown Widget**: A minimal, reusable widget that shows suggestions as the user types
- **Debounced Search**: Prevents excessive API calls by debouncing user input (300ms)
- **Minimum Character Threshold**: Only starts suggesting after 3 or more characters are typed
- **Async Suggestions**: Supports asynchronous data fetching
- **Clean UI**: Uses Flutter's overlay system for accurate dropdown positioning

## Project Structure

```
lib/
  ├── main.dart                    # App entry point
  └── autocomplete_dropdown.dart   # Autocomplete widget and example page
```

## Getting Started

### Prerequisites

- Flutter SDK (2.19.0 or higher)
- Dart SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/apkarthik/test_repo.git
cd test_repo
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

The `AutocompleteDropdown` widget can be used in your Flutter apps:

```dart
AutocompleteDropdown(
  hintText: 'Search...',
  fetchSuggestions: (query) async {
    // Your async lookup logic here
    return await yourAsyncLookup(query);
  },
  onSelected: (selected) {
    print('Selected: $selected');
  },
)
```

### Parameters

- `fetchSuggestions`: Required callback that returns a `Future<List<String>>` based on the query
- `onSelected`: Optional callback triggered when a suggestion is selected
- `hintText`: Optional hint text for the input field

## Example

The app includes an example page (`AutocompleteExamplePage`) that demonstrates the widget with a list of fruits. Type 3 or more characters to see suggestions appear.

## Building Optimized APK

### APK Size Optimization

This project is configured with several optimizations to minimize APK size:

- **Code Shrinking**: ProGuard/R8 minification removes unused code
- **Resource Shrinking**: Removes unused resources from the APK
- **ABI Splits**: Separate APKs for each CPU architecture (arm64-v8a, armeabi-v7a, x86_64)
- **Optimized Gradle Settings**: Efficient heap allocation for faster builds

These optimizations can reduce APK size by 30-50% compared to unoptimized builds.

### Build via GitHub Actions

This repository includes a GitHub Actions workflow to build optimized release APKs:

1. Go to the **Actions** tab in GitHub
2. Select **Build Optimized APK** workflow from the left sidebar
3. Click **Run workflow** button
4. Select the branch and click **Run workflow**
5. Once complete, download your preferred APK from the workflow artifacts:
   - `release-apk-arm64-v8a`: For modern 64-bit ARM devices (smallest, ~10-15MB)
   - `release-apk-armeabi-v7a`: For older 32-bit ARM devices
   - `release-apk-x86_64`: For x86_64 devices (emulators)
   - `release-apk-universal`: Works on all architectures (larger size)

The workflow will:
- Set up Flutter and Java environments
- Build release APKs with code shrinking and resource optimization
- Generate split APKs per CPU architecture for minimal size
- Upload all APK variants as artifacts (retained for 30 days)

### Local Build

To build optimized APKs locally:

```bash
# Build release APK with all optimizations
flutter build apk --release --split-per-abi

# APKs will be at:
# - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# - build/app/outputs/flutter-apk/app-x86_64-release.apk
# - build/app/outputs/flutter-apk/app-release.apk (universal)
```

**Size Comparison** (approximate):
- Debug APK: ~40-50MB
- Release APK (universal): ~15-20MB
- Release APK (per-ABI split): ~10-15MB each

**Note**: Release APKs use a debug signing key for testing. For production distribution, configure proper release signing in `android/app/build.gradle`.