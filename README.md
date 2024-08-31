# ToDo App

ToDo App is a comprehensive task management application designed to help users organize, track, and manage their tasks efficiently. The app is being developed throughout the course to reinforce concepts covered in various lessons, and it will include features for managing tasks, saving data, and integrating with different file formats and APIs.

## 📚 Overview

The ToDo App allows users to create, edit, and manage tasks with various attributes such as importance, deadlines, and completion status. The app also includes functionalities for saving and loading tasks from files, parsing tasks from JSON and CSV formats, and utilizing SwiftUI and UIKit for a user-friendly interface.

### 🎯 Project Objectives

1. **Create a Task Management Interface**: Develop a user interface for creating, editing, and viewing tasks.
2. **Implement Data Storage**: Use multiple storage methods to save and load tasks.
3. **Parse Data**: Handle data parsing for JSON and CSV formats.
4. **Integrate Networking**: Implement client-server interactions for task synchronization.
5. **Apply Modern Swift Features**: Utilize Swift's concurrency features and integrate third-party libraries for enhanced functionality.

## ✨ Features

- **Task Management**: Create, edit, and manage tasks with attributes such as importance, deadlines, and completion status.
- **Color Management**: Create tasks and assign colors to them.
- **Data Persistence**: Save tasks using various storage methods including SwiftData, SQLite, and file-based options (JSON and CSV).
- **Networking**: Synchronize tasks with a server using RESTful APIs. You can also specify a token (key) for server data retrieval in the settings.
- **Filtering and Sorting**: Filter tasks by creation date and importance, and sort them in ascending or descending order. Option to hide completed tasks.
- **UI Enhancements**: Use SwiftUI and UIKit to create a responsive and user-friendly interface, including support for both light and dark themes.

## 📱 Screens and Navigation

1. **Main Screen**: Displays a list of tasks with options to create, view, and edit tasks. Includes functionality for filtering and sorting tasks.
2. **Task Detail View**:
   - **Creation/Editing**: Allows users to input task details, set deadlines, and mark tasks as completed. Supports scrolling, keyboard management, and landscape orientation.
   - **Color Picker**: Users can choose a color for tasks and view it within the task's interface.
3. **Calendar View (UIKit)**:
   - **Calendar Screen**: Displays tasks organized by date. Users can scroll between dates at the top of the screen to quickly navigate and view tasks for specific dates. Includes swipe actions for marking tasks as completed or active.
4. **Settings**:
   - **Storage Options**: Choose between SwiftData, SQLite, and file-based storage (JSON and CSV). Configure settings for handling task storage and retrieval.
   - **Server Token**: Specify the token (key) required for retrieving data from the server.

## 🖼️ Screenshots

| 1. Main Screen                                                                                                     | 2. Task Detail View                                                                                   | 3. Calendar |
|----------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|---------|
| <img src="https://drive.google.com/uc?export=view&id=1ApmWzjwsHpEC9Mn2wwSiWRvnx1MCKNMi" width="180" />  | <img src="https://drive.google.com/uc?export=view&id=1hb_PrQJsbiyCgN2FWSXExlHzdXMs9nyN" width="180" /> <img src="https://drive.google.com/uc?export=view&id=1Q2Rg8KYdZNwfBdnEKEWp24Q-LmaUfOsm" width="180" /> | <img src="https://drive.google.com/uc?export=view&id=1IVwzg_nhuUzXVcq62KvMwsUmiRXiTVQr" width="180" /> |

| 3. Settings                                                                                                                                                                  |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://drive.google.com/uc?export=view&id=1EA1gew64VgDH3HMiCiHX6zVdldAiPWnL" width="180" />  <img src="https://drive.google.com/uc?export=view&id=1ldVpDAIoF3iiDVd12nARFa6RorbUTcAE" width="180" /> <img src="https://drive.google.com/uc?export=view&id=1fxDkON2PKcCimhzXcBMN449cJSPDvA00" width="180" /> |

## 🛠️ Technologies Used 

### General
- **SwiftUI**: Framework for building user interfaces across all Apple platforms.
- **UIKit**: Framework for constructing and managing graphical, event-driven user interfaces in iOS apps.
- **Combine**: Framework for handling asynchronous events and data streams.
- **SwiftConcurrency**: Modern concurrency model for handling asynchronous tasks and parallel operations.

### Storage
- **SwiftData**: Swift's data management framework for handling data models and persistence.
- **SQLite**: Lightweight, disk-based database for efficient data storage.
- **Keychain**: Securely stores sensitive data such as passwords and authentication tokens.

### Dependencies
- **CocoaLumberjack**: Flexible logging framework for iOS and macOS apps.
- **SwiftLint**: Tool for enforcing Swift style and conventions.

## 🚀 Installation 

The application was developed during a summer bootcamp by Yandex and is not available for public release.

## 📋 Requirements 

- iOS 17.0 or later.

## 👥 Contributors 

- **Trofim Petyanov** – Developer.

## ⚖️ License 

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
