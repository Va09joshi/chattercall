<!-- Title -->
<h1 align="center">ChatterCall 📞💬</h1>

<p align="center">
  A real-time audio/video calling web app built with Flutter and Firebase WebRTC.
</p>

---

## 🚀 Demo

<!-- Replace these with actual screenshots -->
<p align="center">
  <img src="screenshots/home.png" alt="Home Screen" width="400"/>
</p>
<p align="center">
  <img src="screenshots/call.png" alt="Call UI" width="400"/>
</p>

---

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
├── lib/
│ ├── auth/ # Sign in / Sign up / OTP screens
│ ├── pages/ # Home, Call, Profile
│ ├── models/ # Usermodel, Firebase helpers
│ ├── video_call/ # WebRTC logic and UI
│ └── main.dart
├── assets/ # Images, logos, etc.
├── pubspec.yaml
└── README.md

--- 

<h3>## 🛠️ Setup Instructions</h3>

<h4>### 1. Clone the repository</h4>
```bash
git clone https://github.com/Va09joshi/chattercall.git
cd chattercall
```
<h4>2. Install Flutter dependencies</h4>

```bash
flutter pub get
```

<h4>3. Configure Firebase</h4>

<li>Create a Firebase project</li>
<li>Add google-services.json and GoogleService-Info.plist</li>
<li>Enable Authentication (Phone/Email) and Firestore</li>



<h4>4. Run the app</h4>
```bash

flutter run -d chrome      # for web
flutter run -d android     # for mobile
```
