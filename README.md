<!-- Title -->
<h1 align="center">ChatterCall 📞💬</h1>

<p align="center">
 ChatterCall is a modern, real-time communication app built using Flutter, Firebase, and WebRTC, offering a seamless experience for both audio/video calling and text-based chatting. Designed with a clean, dark-themed UI, the app allows users to register via phone or email authentication, initiate secure one-on-one conversations, and stay connected through smooth video calls or engaging chat sessions. Powered by Firebase for authentication, Firestore for data management, and WebRTC for media streaming, ChatterCall brings together reliable backend services with a visually intuitive frontend for a complete communication solution that works across web and mobile platforms.

</p>

<h2 align="center">📸 Screenshots</h2>

<!-- Row 1 -->
<p align="center">
  <img src="https://github.com/user-attachments/assets/cca49f75-fca2-43bf-ae6e-6015e701b335" alt="Screen 1" width="200"/>
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/7a3ad33f-8b8e-4695-ad3f-a2db5cef07b1" alt="Screen 2" width="200"/>
</p>

<!-- Row 2 -->
<p align="center">
  <img src="https://github.com/user-attachments/assets/785a6c70-23e2-4b82-9516-9dfd6d180ec1" alt="Screen 3" width="200"/>
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/b051425c-76d2-4308-8f37-74654ed23e6b" alt="Screen 4" width="200"/>
</p>

<!-- Row 3 -->
<p align="center">
  <img src="https://github.com/user-attachments/assets/81d3638a-e97a-42fc-be76-1d1d155ceb55" alt="Screen 5" width="200"/>
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/a02e7197-1b8c-403b-a1ae-f7ce52cfac9f" alt="Screen 6" width="200"/>
</p>

<!-- Row 4 -->
<p align="center">
  <img src="https://github.com/user-attachments/assets/6e993b5e-808b-44a9-a7b0-9b6fb6e83e9d" alt="Screen 7" width="200"/>
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/927fa90f-cde7-4153-b713-833426ddb913" alt="Screen 8" width="200"/>
</p>





















## 🧩 Features

- 🔐 Secure one-to-one video & audio calling  
- 📹 WebRTC-powered media transmission  
- 📱 Firebase Authentication & Firestore integration  
- 💬 Minimal dark-themed UI with Room ID access  
- 🎛️ Local + remote video view (stacked layout)  

---

## ⚙️ Tech Stack

| Layer        | Technology            |
|--------------|------------------------|
| Frontend     | Flutter (Web/Mobile)   |
| Backend      | Firebase (Auth, Firestore, Storage) |
| Communication| WebRTC via flutter_webrtc |
| Styling      | Material + Google Fonts |
| State Mgmt   | StatefulWidget & Streams |

---

## 📁 Project Structure
```
chattercall/
├── lib/
│   ├── auth/                  # Sign In, Sign Up, OTP screens
│   │   ├── signin.dart
│   │   ├── signup.dart
│   │   └── otp_verification.dart
│
│   ├── models/                # Data models and Firebase helper functions
│   │   ├── usermodel.dart
│   │   └── firebase_helper.dart
│
│   ├── pages/                 # Main application screens
│   │   ├── mainpage/          # Bottom navigation tabs (Home, Map, Jobs, Wallet)
│   │   │   └── mainpage.dart
│   │   ├── profile/           # Profile-related UI
│   │   │   └── profile_screen.dart
│   │   ├── search/            # Search user screen
│   │   │   └── search_page.dart
│   │   └── splashscreen.dart  # App launch splash screen
│
│   ├── video_call/            # WebRTC video calling logic and UI
│   │   ├── video_call_screen.dart
│   │   └── signaling.dart
│
│   ├── utils/                 # Reusable utilities and helpers
│   │   ├── keyword_utils.dart
│   │   └── custom_theme.dart
│
│   └── main.dart              # App entry point
│
├── assets/                    # Fonts, images, icons, etc.
│   ├── images/
│   └── logos/
│
├── pubspec.yaml               # Project dependencies and assets config
└── README.md                  # Project overview and documentation


--- 
```
## 🛠️ Setup Instructions

### 1. Clone the repository
```bash
git clone https://github.com/Va09joshi/chattercall.git
cd chattercall
```
2. Install Flutter dependencies

```bash
flutter pub get
```

3. Configure Firebase
<ul>
<li>Create a Firebase project</li>
<li>Add google-services.json and GoogleService-Info.plist</li>
<li>Enable Authentication (Phone/Email) and Firestore</li>
</ul>



4. Run the app
```bash

flutter run -d chrome      # for web
flutter run -d android     # for mobile
```

<h3>🧠 Future Enhancements</h3>
<li>🔔 Push call notifications</li>
<li>🌍 Group calling support</li>
<li>📊 Call logs and history</li>
<li>📱 iOS compatibility & iPad layout</li>


<h3>🤝 Contributing</h3>

1. Fork the repo

2. Create a branch (feature/your-feature)

3. Commit changes

4. Open a Pull Request

