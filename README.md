# Task Management App

A Flutter-based task management app with offline-first functionality, local and firestore database integration, and advanced UI/UX features including custom animations.

## Features
- **Task Management**: Add, update, delete, and mark tasks as complete.
  - Each task includes:
    - Title
    - Description
    - Priority (High, Medium, Low)
    - Status (Pending, Completed)
    - End Date (a deadline for the task)
- **Offline-First Data Management**: 
  - Local database integration with **ObjectBox** for offline functionality.
  - Sync completed tasks with **Firebase Firestore** when online.
  - Conflict resolution prioritizes the most recent updates during sync.
- **Export & Import**: 
  - Export tasks to an **SQLite** file and import them back into the app.
- **Custom UI with Wave Animation**:
  - Dynamic wave animation on the home screen that:
    - Changes color based on task priority (Red, Blue, Green).
    - Animates based on the completion percentage of tasks.
- **Offline Status Indicator**: Displays online/offline status.
- **End Date Features**:
  - Date picker for setting task deadlines.
  - Tasks that are overdue are highlighted and moved to a separate "Overdue Tasks" section.
  - Tasks approaching deadlines show a warning icon or message.
- **State Management**: Managed using **Provider** for efficient state handling.
- **Bonus Features**:
  - Filtering tasks by priority, status, etc.

## Flutter Version
- **Flutter**: 3.24.3

## Dependencies
- `provider: ^6.1.2`
- `objectbox: ^4.0.3`
- `objectbox_flutter_libs: ^4.0.3`
- `firebase_core: ^3.10.1`
- `cloud_firestore: ^5.6.2`
- `sqflite: ^2.4.1`
- `wave: ^0.2.2`
- `intl: ^0.20.2`
- `connectivity_plus: ^6.1.2`
- `path_provider: ^2.1.5`
- `google_fonts: ^6.2.1`
- `file_picker: ^8.0.0`
- `iconsax: ^0.0.8`

## Architecture Overview

### 1. **Offline-First Design**
The app prioritizes offline functionality by utilizing **ObjectBox** as the local database. Users can add, update, delete, and view tasks even without an internet connection. Once the device goes online, only completed tasks are synced with **Firebase Firestore**, ensuring efficient use of network resources.

### 2. **Task Management System**
Tasks are stored locally using ObjectBox. When a user completes a task, it gets marked as `Completed`, and these tasks are the only ones synced with Firestore. We handle conflict resolution by prioritizing the most recent updates to avoid any inconsistencies.

### 3. **Custom Animations**
Wave animations are created using the `wave` package, dynamically changing colors based on the priority of tasks (Red for High, Blue for Medium, and Green for Low). The wave height also increases in real-time based on the percentage of completed tasks, adding an engaging visual effect.

### 4. **State Management**
We use **Provider** to manage app-wide state, including task list updates, syncing states, and offline status. This ensures that the UI stays updated and consistent with the underlying data.

### 5. **Firebase and Local Sync**
The app syncs completed tasks with Firebase Firestore and uses **ObjectBox** as the local database for offline data persistence. Tasks are stored on the local database and only synchronized with Firestore when online, ensuring low data usage.

## Technologies Used

- **Framework**: Flutter
- **State Management**: Provider
- **Animations**: Wave,AnimationOpacity
- **UI Design**: Material Design

---

## Project Structure

```
lib/
│
├── models/             # Data models for tasks
├── providers/          # State management logic (Provider)
├── services/           # Logic for syncing tasks with Firestore and handling ObjectBox
├── screens/            # UI screens (Home, Task Details, Settings, etc.)
├── widgets/            # Reusable UI components (e.g., Wave Animation)
└── utils/              # Utility functions (e.g., Date pickers, task filtering)

```

---

## Getting Started

### Prerequisites

Make sure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install):version 3.24.4
- [Dart SDK](https://dart.dev/get-dart)
- [Visual Studio Code](https://code.visualstudio.com/) (recommended) with Flutter and Dart extensions

### Installation Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/joesaniya/task_management
   cd lost_found_task_app

## Contact

For any inquiries, please contact:
- **Name**: Esther Jenslin
- **Email**: [estherjenslin1999@gmail.com](mailto:estherjenslin1999@gmail.com)