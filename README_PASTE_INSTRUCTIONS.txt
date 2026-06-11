RC Overall Drive Ratio - Build 1 overlay

How to use:

1. Unzip this folder.
2. Open your Flutter project folder: rc_overall_drive_ratio
3. Copy the lib folder from this overlay into the project root.
4. When Windows asks, replace/merge files.
5. Optional: copy the assets folder into the project root too. It only contains a PDF placeholder for now.
6. Run:

   flutter clean
   flutter pub get
   flutter run -d windows

Notes:
- No pubspec.yaml changes are required for Build 1.
- This build does not use any external packages.
- PDF viewer support will be added after the calculator screen is confirmed working.
