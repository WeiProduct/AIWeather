# App Store Submission Checklist

## Pre-Submission Requirements

### 1. Developer Account ✅
- [ ] Apple Developer Program membership active ($99/year)
- [ ] Certificates and provisioning profiles created
- [ ] App ID configured with proper capabilities

### 2. API Security ✅
- [x] API key removed from source code
- [x] Keychain integration implemented
- [x] Build configuration files created
- [x] .gitignore updated to exclude sensitive files
- [ ] Set actual API key in Release.xcconfig

### 3. App Icons 🟡
- [ ] 1024x1024 App Store icon
- [ ] All required iOS icon sizes generated
- [ ] Icons added to Assets.xcassets

### 4. Screenshots 🟡
- [ ] iPhone 6.7" (1290 × 2796) - 5 screenshots
- [ ] iPhone 6.5" (1242 × 2688) - 5 screenshots  
- [ ] iPhone 5.5" (1242 × 2208) - 5 screenshots
- [ ] iPad Pro 12.9" (2048 × 2732) - Optional

### 5. App Information ✅
- [x] App name and subtitle prepared
- [x] App description (English & Chinese)
- [x] Keywords defined
- [x] Categories selected
- [x] Privacy policy created

### 6. Technical Requirements ✅
- [x] Launch screen implemented
- [x] Performance monitoring added
- [x] Info.plist permissions configured
- [x] Version and build numbers configured
- [x] Export compliance (ITSAppUsesNonExemptEncryption)

### 7. Testing Requirements 🟡
- [ ] Test on real devices
- [ ] Test all iOS versions (15.0+)
- [ ] Test location permissions flow
- [ ] Test notification permissions flow
- [ ] Test without internet connection
- [ ] Memory leak testing
- [ ] Performance profiling

### 8. Code Quality ✅
- [x] No hardcoded API keys in release
- [x] No debug print statements
- [x] Error handling implemented
- [x] Localization complete (EN/ZH)

## Xcode Build Settings

### 1. General Tab
- [ ] Display Name: Weather
- [ ] Bundle Identifier: com.yourcompany.weather
- [ ] Version: 1.0.0
- [ ] Build: 1

### 2. Signing & Capabilities
- [ ] Automatically manage signing: OFF
- [ ] Select proper provisioning profile
- [ ] Capabilities enabled:
  - [x] Location Services
  - [x] Background Modes (fetch, processing)
  - [x] Push Notifications (local only)

### 3. Build Configuration
- [ ] Link Debug.xcconfig to Debug configuration
- [ ] Link Release.xcconfig to Release configuration
- [ ] Set OPENWEATHER_API_KEY in both configs

## App Store Connect Setup

### 1. Create App
- [ ] Sign in to App Store Connect
- [ ] Create new app
- [ ] Fill basic information
- [ ] Set pricing (Free)

### 2. App Information
- [ ] Upload privacy policy URL
- [ ] Set age rating (4+)
- [ ] Add app categories

### 3. Version Information
- [ ] Add app description (all languages)
- [ ] Upload screenshots
- [ ] Add keywords
- [ ] Add support URL
- [ ] Add marketing URL (optional)

### 4. Build Upload
- [ ] Archive in Xcode (Product > Archive)
- [ ] Validate archive
- [ ] Upload to App Store Connect
- [ ] Select build for review

### 5. Submit for Review
- [ ] Answer export compliance questions
- [ ] Add review notes if needed
- [ ] Submit for review

## Post-Submission

### 1. Monitor Review Status
- [ ] Check email for updates
- [ ] Respond to reviewer feedback promptly
- [ ] Be prepared to make changes if rejected

### 2. Release
- [ ] Choose release option (automatic/manual)
- [ ] Monitor crash reports
- [ ] Check user reviews
- [ ] Plan for updates

## Common Rejection Reasons to Avoid

1. **Incomplete functionality** - All features must work
2. **Crashes or bugs** - Test thoroughly
3. **Privacy issues** - Clear privacy policy required
4. **Missing permissions usage descriptions**
5. **Inappropriate content**
6. **Poor user experience**
7. **Misleading app description**
8. **Using private APIs**

## Final Steps Before Submission

1. **Test Release Build**
   ```bash
   # Build release configuration
   xcodebuild -configuration Release
   ```

2. **Remove Debug Code**
   - Search for `print()` statements
   - Remove any debug UI
   - Ensure no test data

3. **Update API Key**
   - Add real API key to Release.xcconfig
   - Test with real API key

4. **Create Archive**
   - Select Generic iOS Device
   - Product > Archive
   - Validate before upload

## Support Information

- Support Email: [your-email@domain.com]
- Support Website: [your-website.com/support]
- Privacy Policy: [your-website.com/privacy]

---

**Note**: This checklist ensures your app meets Apple's guidelines and provides the best chance for approval on first submission.