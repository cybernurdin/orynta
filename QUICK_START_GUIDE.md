# Orynta App - Quick Start Guide

## 🎯 What's Been Built

### Core Infrastructure (100% Complete)
✅ Authentication system with email, password, Google Sign-In, and password reset
✅ Location services with GPS tracking
✅ Weather integration with forecasts
✅ Comprehensive user model with stats tracking
✅ Advanced soil/leaf scan analysis models
✅ Cameroon crops database (20+ crops)
✅ Forum, marketplace, and announcement systems

### UI Widgets & Components (100% Complete)
✅ Professional crop cards with category badges
✅ Forum post cards with engagement metrics
✅ Marketplace product cards with seller info
✅ Responsive grid layouts
✅ Filter and search components

### Ready-to-Use Screens (40% Complete)
- [x] Authentication screens (Login, Signup, Password Reset)
- [x] Dashboard with weather and quick actions
- [x] Crops Directory with search and filters
- [x] Community Forum with announcements
- [x] Marketplace browser
- [ ] Scan results display
- [ ] User profile screen
- [ ] Settings screen

---

## 🚀 Quick Start - Next Steps

### Step 1: Firebase Setup (5 minutes)
```bash
1. Go to https://console.firebase.google.com
2. Create a new project called "Orynta"
3. Enable Authentication:
   - Email/Password
   - Google Sign-In
4. Create Firestore Database (production mode)
5. Download configuration files:
   - google-services.json (Android)
   - GoogleService-Info.plist (iOS)
```

### Step 2: Add Firebase Config Files
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

### Step 3: Get Pub Dependencies
```bash
cd d:\apps\ code\orynta
flutter pub get
```

### Step 4: Run the App
```bash
flutter run -v
```

---

## 📋 File Structure Reference

```
lib/
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── scan_analysis_model.dart
│   │   ├── crop_data.dart (20+ Cameroon crops)
│   │   ├── forum_model.dart
│   │   └── marketplace_model.dart
│   └── services/
│       ├── authentication_service.dart
│       ├── location_service.dart
│       └── weather_service.dart
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── password_reset_screen.dart
│   ├── community/
│   │   └── community_forum_screen.dart
│   ├── crops/
│   │   └── crops_directory_screen.dart
│   ├── home/
│   │   └── dashboard_screen.dart
│   ├── market/
│   │   └── marketplace_screen.dart
│   ├── profile/
│   ├── scan/
│   └── support/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── widgets/
│   │   ├── crop_card.dart
│   │   ├── forum_post_card.dart
│   │   └── marketplace_product_card.dart
│   └── localization/
└── app.dart
```

---

## 🔌 Core Services Usage

### Authentication
```dart
final auth = AuthenticationService();

// Register
await auth.registerWithEmail(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Farmer',
  userType: 'farmer',
);

// Login
await auth.loginWithEmail(email: 'user@example.com', password: 'pass');

// Google Sign In
await auth.signInWithGoogle();

// Password Reset
await auth.sendPasswordResetEmail('user@example.com');

// Get current user
final user = await auth.getCurrentUserModel();
```

### Location
```dart
final location = LocationService();

// Get current position
final pos = await location.getCurrentLocation();
print('${pos.latitude}, ${pos.longitude}');

// Request permissions
final granted = await location.requestLocationPermission();
```

### Weather
```dart
final weather = WeatherService();

// Get current weather
final current = await weather.getWeatherByCoordinates(3.8667, 11.5167);
print('Temperature: ${current.temperature}°C');

// Get forecast
final forecast = await weather.getWeatherForecast(3.8667, 11.5167, days: 7);
```

### Crops Database
```dart
import 'package:orynta/data/models/crop_data.dart';

// Get all crops
final all = CameruCropsDatabase.cropsData;

// Search
final tomatoes = CameruCropsDatabase.searchCrops('tomato');

// By category
final vegetables = CameruCropsDatabase.getCropsByCategory('vegetable');

// By ID
final maize = CameruCropsDatabase.getCropById('maize');

// Categories
final categories = CameruCropsDatabase.getAllCategories();
```

---

## 🎨 Styling & Theme

### Colors (Use from app_colors.dart)
```dart
AppColors.forest        // #1B5E3F (primary green)
AppColors.moss          // #6FA876 (secondary)
AppColors.amber         // #D4AF37 (accent)
AppColors.cream         // #F5EFE7 (background)
AppColors.ink           // #222A1F (text)
```

### Text Styles
```dart
Theme.of(context).textTheme.headlineMedium  // 24px bold
Theme.of(context).textTheme.titleLarge      // 18px bold
Theme.of(context).textTheme.bodyLarge       // 16px
Theme.of(context).textTheme.bodyMedium      // 14px
Theme.of(context).textTheme.bodySmall       // 12px
```

---

## 📱 Screen Navigation Integration

To integrate screens into the app shell, update `lib/features/shell/app_shell.dart`:

```dart
import 'package:orynta/features/home/dashboard_screen.dart';
import 'package:orynta/features/crops/crops_directory_screen.dart';
import 'package:orynta/features/community/community_forum_screen.dart';
import 'package:orynta/features/market/marketplace_screen.dart';

// In your BottomNavigationBar onTap:
_currentIndex = index;
_pageController.jumpToPage(index);

// In PageView children list:
children: [
  const DashboardScreen(),
  const CropsDirectoryScreen(),
  const CommunityForumScreen(),
  const MarketplaceScreen(),
  // ... other screens
],
```

---

## 🔄 Data Flow Example

### Creating a Forum Post
```dart
1. User fills form in CommunityForumScreen
2. Validates input
3. Creates ForumPost model:
   - postId: uuid.v4()
   - userId: auth.currentUser.uid
   - category: user selection
   - createdAt: DateTime.now()

4. Saves to Firestore:
   db.collection('forum_posts').doc(postId).set(post.toJson())

5. Updates user stats:
   auth.updateUserStats(
     uid: userId,
     statKey: 'forumContributions',
     incrementValue: 1,
   )

6. UI updates via Provider/StateManagement
```

---

## 🐛 Common Tasks

### Add a New Crop
```dart
// In lib/data/models/crop_data.dart, add to cropsData list:
CropData(
  id: 'pepper',
  name: 'Pepper',
  category: 'vegetable',
  bestSoilType: 'Sandy loam',
  optimalPh: 6.5,
  // ... fill other fields
),
```

### Add New Forum Category
```dart
// In CommunityForumScreen, update _categories:
final List<String> _categories = [
  'all',
  'soil_management',
  'plant_health',
  'pest_control',
  'technology',
  'success_stories',
  'new_category',  // Add here
];
```

### Customize Theme Colors
```dart
// In lib/core/theme/app_colors.dart:
static const Color forest = Color(0xFF1B5E3F);
static const Color moss = Color(0xFF6FA876);
// ... modify as needed
```

---

## 🧪 Testing Checklist

Before deployment:
- [ ] Test all authentication flows
- [ ] Test location permission handling
- [ ] Test weather API calls
- [ ] Test crop search and filtering
- [ ] Test forum post creation
- [ ] Test marketplace product listing
- [ ] Test on real device (not just emulator)
- [ ] Test with poor internet connection
- [ ] Test dark mode (if implemented)
- [ ] Test on different screen sizes

---

## 📦 Deployment Checklist

### Android
- [ ] Update versionCode and versionName in `pubspec.yaml`
- [ ] Create signing key: `keytool -genkey -v -keystore ~/my-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias`
- [ ] Build release APK: `flutter build apk --release`

### iOS
- [ ] Update version in `ios/Runner/Info.plist`
- [ ] Build release IPA: `flutter build ipa --release`

### Shared
- [ ] Remove debug banners
- [ ] Test error handling
- [ ] Optimize bundle size
- [ ] Configure Firebase production settings
- [ ] Setup analytics

---

## 🆘 Troubleshooting

### Firebase not connecting
- [ ] Verify `google-services.json` in android/app/
- [ ] Verify `GoogleService-Info.plist` in ios/Runner/
- [ ] Check Firebase project ID matches
- [ ] Ensure SHA-1 fingerprint is registered

### Location not working
- [ ] Check `android/app/src/main/AndroidManifest.xml` has permissions
- [ ] Check `ios/Runner/Info.plist` has location keys
- [ ] Test with real device (emulator may not have GPS)

### Weather API slow
- [ ] Use Open-Meteo free API (no rate limit issues)
- [ ] Cache results locally
- [ ] Add loading states

---

## 📚 Resources

- Flutter Docs: https://flutter.dev/docs
- Firebase for Flutter: https://firebase.flutter.dev
- Open-Meteo API: https://open-meteo.com
- Orynta Brand Guide: `./Orynta_Brand_Guide.md`
- Orynta SRS: `./Orynta_SRS.md`

---

## 💡 Pro Tips

1. **Use Provider for state management** - Already imported in app.dart
2. **Cache API responses** - Use SharedPreferences for offline access
3. **Use Firebase Emulator** for local development testing
4. **Implement error handling** with try-catch in all async calls
5. **Add shimmer loaders** while data fetches
6. **Test different orientations** (portrait/landscape)
7. **Monitor app size** - Use `flutter build apk --analyze-size`

---

## 🎓 Learning Paths

### For UI Development
1. Study the existing cards (CropCard, ForumPostCard, MarketplaceProductCard)
2. Create new card variants following the same pattern
3. Use GridView for product/crop lists
4. Use ListView for posts/comments

### For Backend Integration
1. Setup Firestore collections
2. Create data repository classes
3. Use ChangeNotifier or Provider for state
4. Implement CRUD operations

### For New Features
1. Create model class
2. Create service class
3. Create UI screen
4. Add navigation
5. Test thoroughly

---

**Status:** 40% Complete - All Infrastructure Ready
**Last Updated:** January 2025
**Next Priority:** Complete remaining screens and integrate Firebase
