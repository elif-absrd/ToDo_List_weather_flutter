# To-Do List + Weather Flutter App

## Project Description
This is a Flutter-based To-Do List application that integrates real-time weather information based on the user's location. It allows users to add, edit, and delete tasks with due dates and priority settings, persisting data locally using `shared_preferences`. The app is optimized for web (Chrome) and can be extended to other platforms, making it a great starting point for learning Flutter development or building productivity tools. Contributions and enhancements are welcome!

## Getting Started with Flutter

If you're new to Flutter, here are some helpful resources to get started:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Official Flutter Documentation](https://docs.flutter.dev/) – tutorials, samples, and full API reference.

## Setup Instructions

### 1. Clone the Repository
Run the following command to clone the repository:
```bash
git clone https://github.com/elif-absrd/ToDo_List_weather_flutter.git
```
Navigate to the project directory:
```bash
cd ToDo_List_weather_flutter
```

### 2. Check Flutter Installation
Verify that Flutter is installed by running:
```bash
flutter doctor
```
Ensure the output shows no missing dependencies (e.g., Android SDK, Dart, or connected devices). If issues are reported, resolve them before proceeding.

## Flutter SDK Installation Guide (Windows/macOS/Linux)

### Step 1: Download Flutter SDK

**For Windows:**

- Visit: https://flutter.dev/docs/get-started/install/windows  
- Click **"Download Flutter SDK"** (you’ll get a `.zip` file).
- Extract the zip to a preferred location, for example:  
  `C:\flutter`

**For macOS/Linux:**

- Visit: https://flutter.dev/docs/get-started/install/macos  
- Download the `.zip` file and extract it to your home directory:  
  `~/flutter`

---

### Step 2: Add Flutter to System PATH

**Windows:**

1. Open Start Menu → Search **“Environment Variables”**
2. Click **"Edit the system environment variables"**
3. In the **System Properties** window, click **Environment Variables**
4. Under **System Variables**, find and select `Path`, then click **Edit**
5. Click **New**, then enter:  
   `C:\flutter\bin`
6. Click **OK** to save and close all windows

**macOS/Linux:**

1. Open Terminal
2. Run the following (depending on your shell):
   ```bash
   nano ~/.zshrc       # for Zsh
   # or
   nano ~/.bashrc      # for Bash


### 3. Ensure Android Studio Configuration
- Open the project in Android Studio.
- Navigate to:  
  `File > Project Structure > SDK Location`
- Verify that the **Flutter SDK path** is correctly set (e.g., `C:\flutter` on Windows or `~/flutter` on macOS/Linux).
- Ensure the **Android SDK** is configured under:  
  `Appearance & Behavior > System Settings > Android SDK`

### 4. Set Environment Variables

Add the Flutter `bin` directory to your system PATH:

- **Windows**:
  - Edit environment variables and add:
    ```
    C:\flutter\bin
    ```
- **macOS/Linux**:
  - Add the following to your `~/.bashrc` or `~/.zshrc` file:
    ```bash
    export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"
    ```
  - Then apply it with:
    ```bash
    source ~/.bashrc
    ```
    or
    ```bash
    source ~/.zshrc
    ```

Verify the PATH update by running:
```bash
flutter --version
```

### 5. Install Dependencies
Install all project dependencies using:
```bash
flutter pub get
```

### 6. Run the Project
- Make sure a device is connected or select a simulator/emulator (e.g., Chrome).
- Run the app using:
  ```bash
  flutter run
  ```
- When prompted, select Chrome (option 2).
- You can now:
  - Add tasks
  - Set priorities and due dates
  - View real-time weather based on your location
  - Refresh the browser (F5) to test data persistence

## Project Structure
```
ToDo_List_weather_flutter/
├── android/          # Android-specific files
├── ios/              # iOS-specific files
├── lib/              # Dart source files
│   └── main.dart     # Main application logic
├── web/              # Web-specific files
├── test/             # Test files
├── pubspec.yaml      # Project configuration and dependencies
└── README.md         # This file
```
