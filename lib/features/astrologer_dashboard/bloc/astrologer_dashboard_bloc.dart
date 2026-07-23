import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'astrologer_dashboard_event.dart';
import 'astrologer_dashboard_state.dart';

import '../../../core/services/presence_service.dart';

class AstrologerDashboardBloc extends Bloc<AstrologerDashboardEvent, AstrologerDashboardState> {
  final _supabase = Supabase.instance.client;

  AstrologerDashboardBloc() : super(AstrologerDashboardInitial()) {
    on<LoadAstrologerDashboard>(_onLoad);
    on<ToggleOnlineStatus>(_onToggleOnline);
    on<UpdateAstrologerProfile>(_onUpdateProfile);
  }

  Future<void> _onLoad(LoadAstrologerDashboard event, Emitter<AstrologerDashboardState> emit) async {
    emit(AstrologerDashboardLoading());
    try {
      final isUuid = event.astrologerId.length == 36 && event.astrologerId.contains('-');
      final queryCol = isUuid ? 'id' : 'firebase_uid';

      var row = await _supabase
          .from('astrologers')
          .select()
          .eq(queryCol, event.astrologerId)
          .maybeSingle();

      if (row == null && event.firebaseUid.isNotEmpty) {
        row = await _supabase
            .from('astrologers')
            .select()
            .eq('firebase_uid', event.firebaseUid)
            .maybeSingle();
      }

      if (row == null) {
        emit(const AstrologerDashboardError('Astrologer record not found.'));
        return;
      }

      emit(AstrologerDashboardLoaded(
        astrologerId: row['id']?.toString() ?? event.astrologerId,
        firebaseUid: row['firebase_uid']?.toString() ?? event.firebaseUid,
        name: row['name'] ?? '',
        bio: row['bio'] ?? '',
        experienceYears: row['experience_years'] ?? 0,
        languages: List<String>.from(row['languages'] ?? []),
        skills: List<String>.from(row['skills'] ?? []),
        categories: List<String>.from(row['categories'] ?? []),
        chatRate: (row['chat_rate'] as num?)?.toDouble() ?? 5,
        callRate: (row['call_rate'] as num?)?.toDouble() ?? 10,
        videoRate: (row['video_rate'] as num?)?.toDouble() ?? 15,
        rating: (row['rating'] as num?)?.toDouble() ?? 5.0,
        reviewsCount: row['reviews_count'] ?? 0,
        totalMinutesConsulted: row['total_minutes_consulted'] ?? 0,
        isOnline: row['is_online'] ?? false,
        avatarUrl: row['avatar_url'],
      ));
    } catch (e) {
      debugPrint('[AstrologerDashboardBloc] Load error: $e');
      emit(AstrologerDashboardError(e.toString()));
    }
  }

  Future<void> _onToggleOnline(ToggleOnlineStatus event, Emitter<AstrologerDashboardState> emit) async {
    if (state is! AstrologerDashboardLoaded) return;
    final current = state as AstrologerDashboardLoaded;
    final newStatus = !current.isOnline;

    // Optimistic update
    emit(current.copyWith(isOnline: newStatus));

    try {
      await PresenceService().setPresence(
        firebaseUid: current.firebaseUid,
        astrologerId: current.astrologerId,
        isOnline: newStatus,
      );

      final isAstroUuid = current.astrologerId.length == 36 && current.astrologerId.contains('-');
      final queryCol = isAstroUuid ? 'id' : 'firebase_uid';

      try {
        await _supabase
            .from('astrologers')
            .update({
              'is_online': newStatus,
            })
            .eq(queryCol, current.astrologerId);
      } catch (e) {
        debugPrint('[AstrologerDashboardBloc] Error updating by $queryCol: $e');
      }

      if (current.firebaseUid.isNotEmpty) {
        try {
          await _supabase
              .from('astrologers')
              .update({
                'is_online': newStatus,
              })
              .eq('firebase_uid', current.firebaseUid);
        } catch (e) {
          debugPrint('[AstrologerDashboardBloc] Error updating by firebase_uid: $e');
        }
      }

      // If coming online, trigger notifications for waiting users
      if (newStatus == true) {
        try {
          await _supabase
              .from('notify_requests')
              .update({'notified': true})
              .eq('astrologer_id', current.astrologerId)
              .eq('notified', false);
        } catch (_) {}
      }

      debugPrint('[AstrologerDashboardBloc] Online status toggled to $newStatus in both Firestore & Supabase.');
    } catch (e) {
      debugPrint('[AstrologerDashboardBloc] Toggle error: $e');
      // Revert on error
      emit(current.copyWith(isOnline: !newStatus));
    }
  }

  Future<void> _onUpdateProfile(UpdateAstrologerProfile event, Emitter<AstrologerDashboardState> emit) async {
    if (state is! AstrologerDashboardLoaded) return;
    final current = state as AstrologerDashboardLoaded;

    try {
      // 1. Update Supabase
      if (current.astrologerId.isNotEmpty) {
        await _supabase
            .from('astrologers')
            .update(event.updates)
            .eq('id', current.astrologerId);
      }

      if (current.firebaseUid.isNotEmpty) {
        try {
          await _supabase
              .from('astrologers')
              .update(event.updates)
              .eq('firebase_uid', current.firebaseUid);
        } catch (_) {}
      }

      // 2. Prepare comprehensive Firestore payload
      final firestorePayload = <String, dynamic>{
        ...event.updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add camelCase aliases for rates and experience
      if (event.updates.containsKey('chat_rate')) {
        firestorePayload['chatRate'] = event.updates['chat_rate'];
      }
      if (event.updates.containsKey('call_rate')) {
        firestorePayload['callRate'] = event.updates['call_rate'];
      }
      if (event.updates.containsKey('video_rate')) {
        firestorePayload['videoRate'] = event.updates['video_rate'];
      }
      if (event.updates.containsKey('experience_years')) {
        firestorePayload['experienceYears'] = event.updates['experience_years'];
      }
      if (event.updates.containsKey('avatar_url')) {
        firestorePayload['avatarUrl'] = event.updates['avatar_url'];
      }

      // 3. Update Firestore astrologers collection
      if (current.firebaseUid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('astrologers')
            .doc(current.firebaseUid)
            .set(firestorePayload, SetOptions(merge: true));
      }
      if (current.astrologerId.isNotEmpty && current.astrologerId != current.firebaseUid) {
        await FirebaseFirestore.instance
            .collection('astrologers')
            .doc(current.astrologerId)
            .set(firestorePayload, SetOptions(merge: true));
      }

      // 4. Update Firestore presence collection (name and avatar update)
      final presenceUpdates = <String, dynamic>{};
      if (event.updates.containsKey('name')) {
        presenceUpdates['name'] = event.updates['name'];
      }
      if (event.updates.containsKey('avatar_url')) {
        presenceUpdates['avatarUrl'] = event.updates['avatar_url'];
        presenceUpdates['avatar_url'] = event.updates['avatar_url'];
      }

      if (presenceUpdates.isNotEmpty && current.firebaseUid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('presence')
            .doc(current.firebaseUid)
            .set(presenceUpdates, SetOptions(merge: true));
      }

      debugPrint('[AstrologerDashboardBloc] Updated profile in both Supabase & Firestore successfully.');

      // Reload
      add(LoadAstrologerDashboard(
        astrologerId: current.astrologerId,
        firebaseUid: current.firebaseUid,
      ));
    } catch (e) {
      debugPrint('[AstrologerDashboardBloc] Update error: $e');
    }
  }
}
