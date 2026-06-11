# rc_overall_drive_ratio

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Build notes

This package intentionally uses the formatted text version of the Murfdogg tuning guide and has no document-viewer package dependency.

After unzipping, run:

```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

To publish GitHub Pages for the `rc_overall_drive_ratio` repo:

```powershell
flutter build web --base-href /rc_overall_drive_ratio/
Remove-Item -Path docs -Recurse -Force
New-Item -Path docs -ItemType Directory
Copy-Item -Path build\web\* -Destination docs\ -Recurse -Force
New-Item -Path docs\.nojekyll -ItemType File -Force
```

Then commit and push the updated `docs` folder.
