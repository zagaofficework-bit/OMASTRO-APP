# OmAstro Project Memory

## Project Overview
This repository contains the `OMASTRO-APP` Flutter application, which connects to both Firebase (Firestore) and Supabase.

## Active Task: Database Sync & Background Notifications
- **Goal**: Synchronize astrologers' data between Firestore and Supabase, maintaining Supabase as the main datastore and Firestore for real-time signaling, presence, calling, and chats.
- **Background Notifications**: Implement `flutter_background_service` to listen to Firestore calls and messages in the background and show notifications when terminated.
- **Feature Cleanup**: Remove the "Notify Me" feature completely (including the UI prompts, notify service, and DB structures).

## Done So Far
- Fixed the Gradle build issue in `android/build.gradle.kts` by reordering and applying the `compileSdkVersion(36)` override to all subprojects dynamically.
- Removed the deprecated "Notify Me" feature from `astrologer_list_card.dart`, `auth_bloc.dart`, and `astrologers_profile.dart`. Deleted `notify_service.dart`.
- Added the `flutter_background_service` package dependency to `pubspec.yaml`.
- Implemented `FirestoreSyncHelper` in `firestore_sync_helper.dart` to automatically sync astrologers from Supabase to Firestore on start, and called it in `main.dart`.
- Implemented `background_notification_service.dart` to start a background isolate listening to Firestore chats and calls to trigger local notifications when backgrounded or terminated, and initialized it in `main.dart`.
- Fixed registration foreign key constraint error `fk_astrologers_profile_id` during astrologer sign-up by explicitly creating/upserting the `profiles` row first and passing the Supabase Auth UUID to the new `astrologers` row.
- Added a hook in `astrologer_onboarding_page.dart` to execute `FirestoreSyncHelper.syncAstrologersToFirestore()` immediately upon onboarding completion, so new astrologers are added to the Firestore `astrologers` collection in real-time.
- Resolved Android Foreground Service crash on startup on Android 14+ by declaring `FOREGROUND_SERVICE_DATA_SYNC` and setting `foregroundServiceType="dataSync"`.
- Resolved Android Manifest merger error with `flutter_background_service` by adding `xmlns:tools` namespace and using `tools:replace="android:exported"` with `android:exported="true"`.
- Added payload strings to background service notifications for both chats and calls, and implemented call payload routing in `notification_service.dart` to open call screens directly.
- Hooked `PresenceService().setPresence` and `is_online: true` directly into `astrologer_onboarding_page.dart` so that newly registered astrologers are online immediately after onboarding completes.
- Fixed `invalid input syntax for type uuid` query error in `astrologer_chat_room_page.dart` when fetching client details by adding a UUID format check.
- Fixed the Zego login conflict/disconnection error by aligning `userID` formats between `ZegoUIKitPrebuiltCallInvitationService` and `ZegoUIKitPrebuiltCall` (removed `_flutter` suffix).
- Implemented real-time online status validation checks in `live_call_page.dart` and `video_call_page.dart` right before establishing a connection.
- Implemented profile picture uploading to the `'avatars'` Supabase bucket in `astrologer_edit_profile_page.dart` with Firestore sync integration in `astrologer_dashboard_bloc.dart`.
- Added pinch-and-zoom full-screen profile image previewing on the astrologer's side profile page and edit page.
- Successfully verified the build compile correctness.
- Fixed a Dart syntax error in `astrologer_edit_profile_page.dart` and `astrologer_onboarding_page.dart` where the reserved keyword `required` was used as a parameter name in `_buildTextField`. Renamed it to `isRequired`.
- Fixed a compilation error in `astrologer_edit_profile_page.dart` where the `Column` widget wrapping the layout was missing inside `SingleChildScrollView`. Restored the `child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...])` structure.
- Corrected the closing brackets at the end of the `build` method in `astrologer_edit_profile_page.dart` to perfectly close both the `Form` and the `Scaffold` widgets.
- Updated `astrologer_dashboard_bloc.dart` so that when the astrologer updates their avatar, the new `avatarUrl` and `avatar_url` are also synced to the Firestore `presence` collection.
- Updated `_pickAndUploadImage` in `astrologer_edit_profile_page.dart` to dispatch the `UpdateAstrologerProfile` event immediately after a successful upload to save the new avatar instantly to the databases.
- Fixed a bug in `astrologer_consultation_history_page.dart` where the consultation history query was incorrectly filtering by `firebaseUid` instead of the Supabase `astrologerId` (which corresponds to `astrologer_id` in the consultations table).
- Updated `astrologer_consultation_history_page.dart` to fetch earnings separately (preventing PostgREST relationship errors) and to query using an OR condition for both `astrologerId` and `firebaseUid` to retrieve both legacy and new call/video records.
- Updated `live_call_page.dart` and `video_call_page.dart` to pass the `firebase_uid` as `astrologerId` to the `BillingEngine` to remain compatible with database foreign key constraints on the `consultations` table.
- Modified the pre-call online check in `live_call_page.dart` and `video_call_page.dart` to only execute if the caller is a client, bypassing the check when the astrologer starts a call to a client from the chat room.
- Updated `billing_engine.dart` to automatically update the `total_minutes_consulted` column in the `astrologers` table when a call or video call session successfully completes.
- Updated the filters and icon layout mapping in `astrologer_consultation_history_page.dart` to support both legacy types ('Call' / 'Video') and new formats ('Audio Call' / 'Video Call') so call/video categories are correctly classified.
- Created `007_sync_consulted_minutes.sql` containing a PostgreSQL database trigger to automatically increment `total_minutes_consulted` on the backend, bypassing Row Level Security (RLS) limitations.
- Modified `live_call_page.dart` and `video_call_page.dart` to minimize the call to a floating overlay badge instead of terminating it when tapping the custom back button or using the system back gesture.

