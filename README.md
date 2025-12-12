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