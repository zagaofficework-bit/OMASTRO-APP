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
      final row = await _supabase
          .from('astrologers')
          .select()
          .eq('id', event.astrologerId)
          .single();

      emit(AstrologerDashboardLoaded(
        astrologerId: event.astrologerId,
        firebaseUid: event.firebaseUid,
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

      // Also update in Supabase astrologers table
      await _supabase
          .from('astrologers')
          .update({'is_online': newStatus})
          .eq('id', current.astrologerId);

      // If coming online, trigger notifications for waiting users
      if (newStatus == true) {
        await _supabase
            .from('notify_requests')
            .update({'notified': true})
            .eq('astrologer_id', current.astrologerId)
            .eq('notified', false);
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
      await _supabase
          .from('astrologers')
          .update(event.updates)
          .eq('id', current.astrologerId);

      // 2. Update Firestore
      if (current.firebaseUid.isNotEmpty) {
        // Map any snake_case keys from event.updates to whatever Firestore expects, 
        // though typically they can just match. Wait, Firestore may use camelCase or the same.
        // The user's prompt says "using the exact same verified payload".
        await FirebaseFirestore.instance
            .collection('astrologers')
            .doc(current.firebaseUid)
            .set(event.updates, SetOptions(merge: true));
      }

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
