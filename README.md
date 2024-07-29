# Gratitude Journal App

Welcome to the Gratitude Journal App! This app is designed to help you capture your daily moments of gratitude, reflect on them over time, and keep them safe. The app leverages various Flutter packages to provide a seamless and interactive user experience.

## Key Features

- **Daily Journal Entries**: Record something you're grateful for each day.
- **Random Entry Viewer**: View a random past entry to reflect on positive moments. Need to have more than 10 entries.
- **Calendar View**: See when you have entered a gratitude entry.
- **Google Sign-In**: Secure and easy authentication using Google Sign-In.
- **Data Backup**: Safeguard your journal entries by backing them up in Google Drive using encyption.

## Screenshots

### Home Page
![Home Page](screenshots/home_page.png)

### Log Out and Backup
![Log Out and Backup](screenshots/log_out_and_backup.png)

### Login Page
![Login Page](screenshots/login_page.png)

### Previous Gratitude Viewer
![Previous Gratitude Viewer](screenshots/previous_gratitude_viewer.png)

### Restore Previous Backup
![Restore Previous Backup](screenshots/restore_previous_backup.png)

### Share Gratitude
![Share Gratitude](screenshots/share_gratitude.png)

## Packages Used and Their Use Cases

- **bot_toast** - for toast notifications
- **encrypt** - encrypt and decrpyt gratitude entries while backing up to and from Google Drive
- **flutter_dotenv** - manage environment variables for secure configuration
- **flutter_riverpod** - for state management
- **get_it** - service locator pattern for dependency injection
- **go_router** - for navigation and routing within the app
- **google_generative_ai** - generative AI capabilities from Google. Used to get emoji based on gratitude
- **google_sign_in** - Google Sign-In for user authentication
- **googleapis** - accesses various Google APIs for additional functionalities
- **googleapis_auth** - Manages authentication for Google APIs
- **isar** - local database for storing journal entries
- **loading_animation_widget** - loading animations
- **logger** - logging for debugging and error tracking
- **path** - Manages file and directory paths in a cross-platform manner
- **screenshot** -  screenshots of the app's user interface
- **share_plus** - used to share gratitude entries in png format
- **spider** - used to manage assests 
- **table_calendar** - displays a calendar view for selecting dates and reviewing entries


## Getting Started

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/gratitude_journal_app.git
    cd gratitude_journal_app
    ```

2. **Install dependencies**:
    ```bash
    flutter pub get
    ```

3. **Set up Firebase**:
   - Follow the Firebase setup guide for Flutter to add your app to Firebase.
   - Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) and place them in the respective directories.

4. **Add Environment Variables**:
   - Create a `.env` file in the root of your project and add your configuration variables.
   - Get Google AI api key from https://aistudio.google.com/app/apikey

**Note**: The `.env` file and `GoogleService-Info.plist` are missing and need to be configured to run the app successfully.

5. **Run the app**:
    ```bash
    flutter run
    ```


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

