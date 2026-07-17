import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import '../../app/route.dart';
import 'package:go_router/go_router.dart';

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
          callback: (payload) async {
            final newRecord = payload.newRecord;
            if (newRecord['user_id'] == user.id && newRecord['notified'] == true) {
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

              // Show in-app banner alert in foreground
              showInAppNotification(newRecord['astrologer_id']?.toString() ?? '', name);
            }
          },
        )
        .subscribe();
  }

  /// Display a beautiful floating alert banner contextually inside the app on any screen
  static void showInAppNotification(String astrologerId, String name) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    // Trigger local snackbar banner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFFFFBF2),
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        duration: const Duration(seconds: 8),
        content: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name is now online! 🟢',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap Connect to consult now',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                rootNavigatorKey.currentContext?.push(
                  '/astrologer-profile',
                  extra: {'id': astrologerId, 'name': name},
                );
              },
              child: const Text(
                'Connect',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
