# Flutter UX Testing Guide

## How to Use the JSON Prompt

### Quick Start
1. **Load the JSON** into Claude or any AI assistant
2. **Provide your app context**:
   - Flutter version (`flutter --version`)
   - Key dependencies (`pubspec.yaml`)
   - App description (what does it do?)
   - Architecture overview (GetX, Riverpod, Provider, etc?)
   - Known issues (if any)

3. **Provide access to code**:
   - Share GitHub repo link OR
   - Upload source files (dart/yaml) OR
   - Describe features verbally with screenshots

4. **Get systematic analysis** across all 10 test categories
5. **Review error report** and prioritize by severity

---

## Test Categories Breakdown

### 1. **UI & Visual Design** (UI_001 - UI_005)
- ✅ Multi-screen compatibility
- ✅ WCAG contrast ratios
- ✅ Typography consistency
- ✅ Spacing and alignment
- ✅ Design system compliance

**Common Issues Found:**
- Text overflow on small screens
- Touch targets < 48dp (should be 44-48dp min)
- Inconsistent padding (8dp, 12dp, 16dp grid)
- Poor contrast on dark mode
- Mismatched font sizes across screens

---

### 2. **Navigation & Flow** (NAV_001 - NAV_004)
- ✅ All routes working
- ✅ State preservation on back
- ✅ Smooth animations (60fps)
- ✅ Double-tap safety
- ✅ Deep linking

**Common Issues Found:**
- Broken routes causing crashes
- Lost form data on navigation
- Jank during page transitions
- Back button not popping routes
- Memory leaks from Navigator stack

---

### 3. **Forms & Input** (FORM_001 - FORM_005)
- ✅ Input validation
- ✅ Error messages clear
- ✅ Keyboard handling
- ✅ No duplicate submissions
- ✅ Date/time picker UX

**Common Issues Found:**
- Wrong keyboard type (email shows number)
- Error messages appear in wrong spot
- Validation triggers only on submit (should be real-time)
- Copy-paste broken on restricted inputs
- Date picker doesn't respect locale

---

### 4. **Data Display & Lists** (DATA_001 - DATA_005)
- ✅ ListView performance (60fps)
- ✅ Real-time updates without lag
- ✅ Search/filter functionality
- ✅ Pull-to-refresh
- ✅ Pagination ("Load More")

**Common Issues Found:**
- Frame drops when scrolling 100+ items
- Duplicate items after pagination
- Memory grows unbounded
- Search causes UI freeze
- Empty state not shown

---

### 5. **Error Handling** (ERROR_001 - ERROR_004)
- ✅ Network errors show clearly
- ✅ Exceptions don't crash
- ✅ Permission/auth errors handled
- ✅ State recovery after crash

**Common Issues Found:**
- Toast disappears too fast
- Stack traces shown to user
- No retry button on network error
- Session timeout crashes app
- Form data lost on network error

---

### 6. **Performance** (PERF_001 - PERF_005)
- ✅ Startup < 3 seconds
- ✅ 60fps animations
- ✅ No memory leaks
- ✅ Runs on older devices
- ✅ Battery optimized

**Common Issues Found:**
- Cold start > 5 seconds
- Jank when loading data
- Memory doesn't release after navigation
- App slow on Pixel 3 (2018)
- Images load unoptimized

---

### 7. **Accessibility** (A11Y_001 - A11Y_005)
- ✅ Screen reader labels
- ✅ Keyboard navigation
- ✅ 200% text scaling
- ✅ Color contrast (4.5:1)
- ✅ Haptic feedback

**Common Issues Found:**
- Icon buttons missing semantic labels
- Focus indicators invisible
- Layout breaks with large fonts
- Red/green only color coding (colorblind fail)
- No keyboard alternative to gesture

---

### 8. **Device Compatibility** (DEVICE_001 - DEVICE_005)
- ✅ Android 8+ to 15
- ✅ iOS 12+ to 18
- ✅ Portrait/landscape
- ✅ Notches handled
- ✅ Tablets (foldables)

**Common Issues Found:**
- App crashes on Android 8
- Landscape orientation breaks
- Content hidden behind notch
- SafeArea ignored
- Different look on old iOS

---

### 9. **Offline & Connectivity** (OFFLINE_001 - OFFLINE_003)
- ✅ Cached data when offline
- ✅ Graceful timeouts
- ✅ Connection switching
- ✅ Retry mechanisms

**Common Issues Found:**
- Offline message confusing
- No retry button
- Slow network causes timeout
- WiFi to 4G switch loses data
- No sync when connection restored

---

### 10. **Security** (SEC_001 - SEC_003)
- ✅ Passwords not logged
- ✅ API keys secure
- ✅ Tokens in secure storage
- ✅ Input validation
- ✅ HTTPS enforced

**Common Issues Found:**
- JWT token in shared prefs (insecure)
- API key in code
- User input not validated
- Self-signed cert crashes app
- Passwords in logs

---

## Error Report Template (Fill This In)

```
┌─────────────────────────────────────────────────────────────┐
│ FLUTTER UX ERROR REPORT                                     │
├─────────────────────────────────────────────────────────────┤
│ Test ID:        UI_001                                      │
│ Severity:       HIGH ⚠️                                      │
│ Category:       UI & Visual Design                          │
├─────────────────────────────────────────────────────────────┤
│ Title:          Text Overflow on Button Labels              │
│                                                             │
│ Description:                                                │
│ "Create Workout" button text overflows on 4.5" phones      │
│ (Pixel 3a). Text renders as "Create..." with ellipsis.     │
│ Happens in portrait & landscape.                           │
│                                                             │
│ Steps to Reproduce:                                         │
│ 1. Open app on Pixel 3a (4.6" screen)                      │
│ 2. Navigate to Workout Screen                              │
│ 3. Observe "Create Workout" button                         │
│                                                             │
│ Expected:                                                   │
│ Full text "Create Workout" visible, button wraps or        │
│ text size reduces, touch target stays 48dp+                │
│                                                             │
│ Actual:                                                     │
│ Text cuts off to "Create..." with truncation. Button       │
│ tap works but UX is unclear.                               │
│                                                             │
│ Affected Devices:                                           │
│ • Pixel 3a (4.6") - occurs                                 │
│ • iPhone SE 1st Gen (4.7") - occurs                        │
│ • Pixel 4a (5.8") - doesn't occur                          │
│                                                             │
│ Impact:                                                     │
│ Users on small phones don't know what button does.         │
│ Affects primary action (create workout). Moderate          │
│ UX degradation.                                            │
│                                                             │
│ Suggested Fix:                                              │
│ Option A: Use flexible button with:                        │
│   - maxLines: 1, overflow: TextOverflow.ellipsis           │
│   - Padding reduced to 12dp horizontal                     │
│   - Font size 13sp instead of 14sp                         │
│                                                             │
│ Option B: Increase button width to 100% screen width       │
│   - Remove padding constraints on small screens            │
│   - Use MediaQuery to adjust width                         │
│                                                             │
│ Reproducible:   YES ✅                                      │
│ Priority:       FIX BEFORE RELEASE                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Common Errors by Category

### 🔴 CRITICAL (Fix Immediately)
- **App crashes on startup** → Check pubspec.lock, null safety issues
- **Infinite loop in build()** → Check setState() logic
- **Data loss on navigation** → Add PageStorageKey or use Provider
- **Security breach** (tokens logged) → Move to flutter_secure_storage
- **Unhandled exception on API error** → Add try-catch, show user message

### 🟠 HIGH (Fix Before Release)
- **Text overflow on buttons** → Adjust font size or button width
- **Forms lose data on rotation** → Use RestorationId or state management
- **Network timeouts without retry** → Add retry button, exponential backoff
- **Bad color contrast** → Use contrast checker (WebAIM)
- **Missing back button** → Add AppBar with automaticallyImplyLeading: true

### 🟡 MEDIUM (Fix Soon)
- **Lag on list scroll** → Use ListView.builder, avoid heavy widgets
- **Missing error messages** → Show SnackBar/Toast on failure
- **Accessibility missing** → Add Semantics() and alt text
- **Date format inconsistent** → Use intl package with locale
- **Orientation change loses scroll position** → Use ScrollController with restoration

### 🟢 LOW (Polish/Refactor)
- **Inconsistent spacing** → Define spacing constants
- **Old API deprecation warnings** → Update to new APIs
- **Font inconsistency** → Use TextTheme from ThemeData
- **Missing loading indicator** → Add CircularProgressIndicator
- **Slow animations** → Reduce duration from 500ms to 200ms

---

## Quick Checklist for Your App

- [ ] Test on Pixel 3a (4.6") and iPad Pro (12.9")
- [ ] Check text sizes at 150% system scale
- [ ] Verify no red/orange errors in Flutter console
- [ ] Run `flutter analyze` (0 warnings)
- [ ] Test with network disabled (flight mode)
- [ ] Test with screen reader enabled (TalkBack/VoiceOver)
- [ ] Rotate device 10 times, check state preserved
- [ ] Scroll list to 500 items, check FPS in DevTools
- [ ] Verify back button works from every screen
- [ ] Check app memory in Android Studio Profiler
- [ ] Test on device 3+ years old
- [ ] Verify no API keys in git history
- [ ] Check all links/routes not hardcoded

---

## How to Debug Issues

### Performance Issues
```bash
# Enable performance overlay
flutter run --profile
# Then in DevTools (connected via browser):
# 1. Open DevTools → Performance tab
# 2. Record 10 second interaction
# 3. Look for yellow/orange frames (slower than 60fps)
# 4. Check memory graph for leaks
```

### Visual Issues
```bash
# Toggle accessibility (text scaling)
# Android: Settings → Accessibility → Text and display size → 200%
# iOS: Settings → Accessibility → Display & Text Size → 200%

# Enable slow animations
# In DevTools: Device toolbar → Slow Animations toggle
```

### Null Safety Issues
```bash
# Check for null safety violations
flutter analyze --no-preamble | grep "error"

# Run with debug assertions
flutter run --debug
```

### Memory Leaks
```bash
# Check for leaks in Android Studio Profiler
# 1. Run app in profile mode
# 2. Navigate in circles 10 times
# 3. Force GC (garbage collection)
# 4. Memory should return to baseline
```

---

## Prioritization Matrix

| Severity | Impact | Effort | Fix When |
|----------|--------|--------|----------|
| Critical | App broken | Any | Immediately |
| High | Core UX broken | < 2hrs | Before release |
| Medium | Accessibility/polish | < 1hr | This sprint |
| Low | Nice-to-have | < 30min | Next sprint |

---

## Tools Recommended

- **Flutter DevTools** - Performance, memory, logging
- **Android Studio Profiler** - Memory leaks, frame rates
- **WebAIM Contrast Checker** - Color accessibility
- **Accessibility Scanner** (Android) - A11y audit
- **Xcode Instruments** (iOS) - Performance profiling
- **BetterCodeHub** - Code quality metrics

