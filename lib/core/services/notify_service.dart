import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class NotifyService {
  static final _supabase = Supabase.instance.client;

  /// Request to be notified when an offline astrologer comes online
  static Future<bool> requestNotification({
    required String astrologerId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Check if duplicate already exists
      final existing = await _supabase
          .from('notify_requests')
          .select()
          .eq('user_id', user.id)
          .eq('astrologer_id', astrologerId)
          .maybeSingle();

      if (existing != null) {
        debugPrint('[NotifyService] Notification request already exists');
        return true; // Return true as it's already registered
      }

      // Insert new request
      await _supabase.from('notify_requests').insert({
        'user_id': user.id,
        'astrologer_id': astrologerId,
        'notified': false,
      });

      debugPrint('[NotifyService] Notification request added successfully for astro: $astrologerId');
      return true;
    } catch (e) {
      debugPrint('[NotifyService] Error requesting notification: $e');
      return false;
    }
  }

  /// Listen for when an offline astrologer comes online
  static void listenForNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Eagerly init so the user can grant permission BEFORE a notification arrives!
    await NotificationService().init();

    _supabase
        .channel('public:notify_requests')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notify_requests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) async {
            final newRecord = payload.newRecord;
            if (newRecord['notified'] == true) {
              debugPrint('[NotifyService] Astrologer ${newRecord['astrologer_id']} is now online!');
              
              // Get Astrologer Name (we can query the astrologers table)
              String name = "An Astrologer";
              try {
                final astro = await _supabase
                    .from('astrologers')
                    .select('name')
                    .eq('id', newRecord['astrologer_id'])
                    .maybeSingle();
                if (astro != null) {
                  name = astro['name'];
                }
              } catch (_) {}

              // Show local notification
              NotificationService().showChatNotification(
                title: 'Astrologer Online! 🟢',
                body: '$name is now online and available for consultation.',
              );
            }
          },
        )
        .subscribe();
  }
}
