# Caregiver App

This repository is part of the thesis project:
Design of an End-to-End IoT System for Monitoring Vulnerable Users

It contains the mobile application that provides information about the wearers of the bracelet trackers.

The complete system consists of three software components:

Cloud Python Server
Flutter Android Application for Caretakers
(Current Repository)
Firmware for the Bracelet Tracker
Repository: https://github.com/tomasvenda/bracelet

## Feature-first architecture 

- This application follows a feature first architecture. Each feature folder contains its UI, logic, and data structures.
- Shared logic and data models live in `lib/core` and `lib/services`
- Native platform folders (`android/`, `ios/`, etc.) hold platform-specific configs. The app source code lives under `lib/`.

## Project structure 

- **Project metadata**: [pubspec.yaml](pubspec.yaml) — lists dependencies, assets, and package info.
- **App entry**: [lib/main.dart](lib/main.dart) — app startup, dependency initialization, routing, and the `runApp()` call.
- **Firebase config**: [lib/firebase_options.dart](lib/firebase_options.dart) — generated Firebase configuration used at startup.
- **Shared core code**: [lib/core/](lib/core/) — reusable building blocks:
	- Models: [lib/core/models/](lib/core/models/) — Bracelet Model Data Structure used across all features.
	- Services/helpers: [lib/core/services/](lib/core/services/) — App ID generation.
	- Utils: [lib/core/utils/](lib/core/utils/) — Date and Time Formatters.
- **Features**: [lib/features/](lib/features/) — each subfolder is a self-contained feature:
	- Dashboard: [lib/features/dashboard/](lib/features/dashboard/)
	- Pairing: [lib/features/pairing/](lib/features/pairing/)
	- Bracelet details: [lib/features/bracelet_details/](lib/features/bracelet_details/)
- **Services**: [lib/services/api_service.dart](lib/services/api_service.dart) is the only service that calls the backend API methods.


## Android APK
For a quick preview of the application, an apk is provided in [here](./test/app-release.apk)