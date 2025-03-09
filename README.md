# 🎓 Campus Trade

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.5.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.0.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

*A secure campus-exclusive marketplace for students* 🚀

Connect, Trade, and Thrive in Your Campus Community! 🌟

</div>

## ✨ Features

### 🔐 Student Authentication
- 📧 Sign up with university email
- 🔄 Google Sign-In with edu domain
- 🛡️ Secure student verification
- 💾 Persistent login state
- 🎓 University-specific access

### 🏪 Marketplace Features
- 📚 Buy and sell textbooks
- 🏠 Find student housing and roommates
- 📱 Trade electronics and gadgets
- 🪑 Rent furniture and appliances
- 🎮 Exchange gaming gear
- 📝 Post and manage listings

### 🎨 Smart Interface
- 🌈 Modern, campus-themed design
- ✨ Smooth animations
- 📱 Mobile-responsive layout
- 🌙 Eye-friendly dark mode
- 🎯 Category-based navigation
- ⚡ Real-time updates

### 📸 Media Management
- 📤 Multiple product photos
- 🗜️ Smart image compression
- 🖼️ Preview and gallery view
- ⚡ Quick upload optimization

### 🔒 Student Safety
- ✅ Verified student accounts
- 👥 In-campus meetings
- 💬 Secure messaging
- 🚫 Spam prevention
- ��️ Report system

## 📱 App Screenshots

<div align="center">

### 🔐 Authentication & Onboarding

<table>
  <tr>
    <td width="33%">
      <img src="screenshots/splash.png" alt="Splash Screen" title="Splash Screen"/>
      <br />
      <em>Splash Screen</em>
    </td>
    <td width="33%">
      <img src="screenshots/login.png" alt="Login Screen" title="Login Screen"/>
      <br />
      <em>Student Login</em>
    </td>
    <td width="33%">
      <img src="screenshots/verification.png" alt="Student Verification" title="Student Verification"/>
      <br />
      <em>Email Verification</em>
    </td>
  </tr>
</table>

### 🏪 Marketplace & Listings

<table>
  <tr>
    <td width="33%">
      <img src="screenshots/home.png" alt="Home Screen" title="Home Screen"/>
      <br />
      <em>Home Feed</em>
    </td>
    <td width="33%">
      <img src="screenshots/search.png" alt="Search Screen" title="Search Screen"/>
      <br />
      <em>Smart Search</em>
    </td>
    <td width="33%">
      <img src="screenshots/details.png" alt="Product Details" title="Product Details"/>
      <br />
      <em>Item Details</em>
    </td>
  </tr>
</table>

### 💬 Messaging & Profile

<table>
  <tr>
    <td width="33%">
      <img src="screenshots/chat.png" alt="Chat Screen" title="Chat Screen"/>
      <br />
      <em>Secure Chat</em>
    </td>
    <td width="33%">
      <img src="screenshots/profile.png" alt="Profile Screen" title="Profile Screen"/>
      <br />
      <em>Student Profile</em>
    </td>
    <td width="33%">
      <img src="screenshots/add_item.png" alt="Add Item Screen" title="Add Item Screen"/>
      <br />
      <em>List Item</em>
    </td>
  </tr>
</table>

</div>

> Note: These screenshots showcase the app's dark theme. Light theme is also available.

## 🚀 Getting Started

### 📋 Prerequisites
```
📱 Flutter SDK (3.5.0 or higher)
💻 Dart SDK (3.0.0 or higher)
🛠️ Android Studio / VS Code
🔥 Firebase account
🐙 Git
```

### ⚙️ Installation

1. **Clone the repository** 📥
```bash
git clone https://github.com/yourusername/campus_trade.git
cd campus_trade
```

2. **Install dependencies** 📦
```bash
flutter pub get
```

3. **Configure Firebase** 🔥
- Create a new Firebase project
- Add Android app to Firebase project
- Download `google-services.json` and place it in `android/app/`
- Enable Email/Password and Google Sign-In authentication methods
- Set up Cloud Firestore with appropriate security rules
- Configure Firebase Storage

4. **Run the app** 🚀
```bash
flutter run
```

### 🔥 Firebase Security Rules

```javascript
// 📝 Firestore rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isVerifiedStudent() {
      return request.auth != null && 
             exists(/databases/$(database)/documents/students/$(request.auth.uid));
    }

    match /users/{userId} {
      allow read: if isVerifiedStudent();
      allow write: if request.auth.uid == userId;
    }
    
    match /products/{productId} {
      allow read: if isVerifiedStudent();
      allow create: if isVerifiedStudent();
      allow update, delete: if request.auth.uid == resource.data.sellerId;
    }
    
    match /students/{studentId} {
      allow read: if isVerifiedStudent();
      allow write: if request.auth.uid == studentId;
    }
  }
}

// 🗄️ Storage rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## 📱 Key Features

- 🎓 **Campus-Exclusive**: Only verified students can access the marketplace
- 💰 **Smart Pricing**: Compare with similar items in your campus
- 📍 **Location Services**: Find items near your dorm or campus buildings
- 💬 **In-App Messaging**: Communicate safely within the app
- 🤝 **Meet-up Spots**: Suggested safe meeting locations on campus
- 📅 **Availability Scheduler**: Coordinate meetups efficiently
- 🏷️ **Category Filters**: Find exactly what you need
- ⭐ **Ratings & Reviews**: Build trust in the community

## 🔧 Troubleshooting

### Common Issues and Solutions

1. **🔄 Build Errors**
   - Clean the project: `flutter clean`
   - Get dependencies: `flutter pub get`
   - Rebuild: `flutter run`

2. **🎓 Student Verification Issues**
   - Ensure using university email
   - Check email verification status
   - Contact support if verification fails

3. **📸 Image Upload Issues**
   - Check camera/storage permissions
   - Verify file size limits
   - Ensure strong internet connection

## 🤝 Community Guidelines

1. 📚 Only list items relevant to student life
2. 💯 Be honest about item condition
3. 🤝 Honor your commitments
4. 🔒 Meet in safe campus locations
5. 📝 Report suspicious activity

## 🆘 Support

We're here to help make campus trading safe and easy!

- 📧 Email: jaypatel3261@gmail.com
- 🐛 Report issues on [GitHub](https://github.com/yourusername/campus_trade/issues)

---

<div align="center">

Made with ❤️ for Students, by Students

⭐ Star us on GitHub — it helps other students find us!

</div>
