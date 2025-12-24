# LayerX Generator

## Overview

`layerx_generator` helps you bootstrap Flutter projects with a **production-ready LayerX architecture**.  
It generates a structured `lib/app/` directory following MVVM principles, preconfigured with GetX,
core services, and extensible modules—so you can focus on building features instead of setup.

---

## Key Features

- **LayerX MVVM Structure** – Organized `model`, `view`, and `view_model` layers
- **GetX Ready** – Navigation, bindings, and state management preconfigured
- **Core Services Included** – HTTP service, shared preferences helper, and JSON extractor
- **Notification Infrastructure (v2.0.2)** – Notification-ready services without forcing Firebase setup
- **Responsive UI Support** – Designed to work seamlessly with `flutter_screenutil`
- **Flexible Usage** – Run via CLI or programmatically

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  layerx_generator: ^2.0.2
````

Then install dependencies:

```sh
flutter pub get
```

---

## Usage

### CLI

Generate the LayerX structure in your project root by running:

```sh
dart run layerx_generator --path .
```

This command creates the complete LayerX (MVVM) architecture under `lib/app/`
without modifying your existing `pubspec.yaml`.

---

### Programmatic

You can also invoke the generator programmatically:

```dart
import 'package:layerx_generator/layerx_generator.dart';
import 'dart:io';

void main() async {
  final generator = LayerXGenerator(Directory.current.path);
  await generator.generate();
}
```

---

## Generated Structure

```text
lib/app/
├── config/
├── mvvm/
│   ├── model/
│   ├── view/
│   └── view_model/
├── repository/
│   ├── auth_repo/
│   ├── firebase/
│   ├── local_db/
│   └── apis/
├── services/
│   ├── notifications/
│   ├── xyz/
│   ├── xyz/
│   ├── xyz/
│   └── xyz/
└── widgets/
```

### Additionally

* `app_widget.dart` is configured with **GetX** and **ScreenUtil**
* `main.dart` is updated to bootstrap the app correctly

---

## Example

A complete working example is available in the `example/` directory.

---

## Changelog

### 2.0.2 – 2025-08-24

* Added notification services under `services/notifications`
* FCM permission handling and local notification hooks
* Foreground, background, and notification-tap handling
* Timezone-aware scheduled notifications
* Device token utilities and secure FCM server key helper
* Notification-ready setup without mandatory Firebase initialization

### 2.0.1

* Optimized HTTP networking
* Improved concurrency, retries, caching, and observability

### 2.0.0

* Removed automatic `pubspec.yaml` modification to avoid overwriting user configs

---

## Contributing

Contributions, issues, and feature requests are welcome.
Feel free to open a pull request or issue on GitHub.

---

## Maintainer

**Umair Hashmi**
GitHub: [https://github.com/umair-hashmii](https://github.com/umair-hashmii)

---

## Resources

* LayerX Website: [https://layer-x.netlify.app/](https://layer-x.netlify.app/)
* GitHub Repository: [https://github.com/Umaiir11/layerx_generator](https://github.com/Umaiir11/layerx_generator)
* Architecture Blog: [https://medium.com/@iam.umairimran/layerx-architecture-8e9415d9d624](https://medium.com/@iam.umairimran/layerx-architecture-8e9415d9d624)

---

## License

Licensed under the **BSD 3-Clause License**.
See the `LICENSE` file for details.



