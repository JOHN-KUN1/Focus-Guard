# Focus-Guard 🛡️

**Reclaim your time, one task at a time.**

Focus-Guard is a premium Flutter-based productivity application designed to help you stay focused by physically locking distracting apps behind a non-bypassable barrier. Unlike traditional timers, Focus-Guard requires you to complete your real-world tasks before it grants you access to your most distracting applications.

---

## ✨ Features

- **App Locking**: Select any installed app (social media, games, etc.) to be locked.
- **Task Integration**: Apps remain locked until you mark your designated tasks as "Done."
- **Immersive Overlay**: A sleek, full-screen UI that prevents you from entering distracting apps.
- **Premium Aesthetics**: High-end dark mode design with glassmorphism and smooth gradients.
- **Foreground Monitoring**: Reliable app detection that works in the background.

## 🚀 How It Works

1.  **Add Your Focus Tasks**: Define what you need to get done.
2.  **Select Your "Distractions"**: Pick the apps that usually eat up your productivity.
3.  **Automatic Lock**: When you try to open a locked app, Focus-Guard will intervene and show your current task list.
4.  **Gain Access**: Once you finish your tasks and mark them off, your apps are unlocked.

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Overlay**: `flutter_overlay_window`
- **Background Service**: `flutter_foreground_task`
- **State Management**: `provider`
- **Storage**: `sqflite` (SQLite) for task persistence.

## 📦 Installation (Development)

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/JOHN-KUN1/Focus-Guard.git
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

> [!IMPORTANT]
> This app requires **Overlay Permission** and **Usage Access** to detect and block apps effectively. The app will guide you through granting these permissions on the first launch.

## 🎨 Screenshots

*(Coming soon... Use your `generate_image` tool if you'd like me to mock up some UI graphics for you!)*

---

Developed with ❤️ using **Antigravity AI**.
