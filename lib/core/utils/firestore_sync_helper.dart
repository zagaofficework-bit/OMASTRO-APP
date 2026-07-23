import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class FirestoreSyncHelper {
  static final _supabase = Supabase.instance.client;
  static final _firestore = FirebaseFirestore.instance;

  /// Synchronize all astrologers from Supabase to Firestore
  static Future<void> syncAstrologersToFirestore() async {
    try {
      debugPrint('[FirestoreSyncHelper] Starting synchronization of astrologers from Supabase to Firestore...');
      
      // 1. Fetch all astrologers from Supabase
      final response = await _supabase.from('astrologers').select();
      final List<Map<String, dynamic>> astrologers = (response as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      if (astrologers.isEmpty) {
        debugPrint('[FirestoreSyncHelper] No astrologers found in Supabase.');
        return;
      }

      final WriteBatch batch = _firestore.batch();
      int operationCount = 0;

      // 2. Map and add each astrologer to the batch
      for (final astro in astrologers) {
        final String uuid = astro['id']?.toString() ?? '';
        final String firebaseUid = astro['firebase_uid']?.toString() ?? '';
        
        // Target document ID in Firestore: Prefer firebase_uid, fallback to uuid
        final String targetDocId = firebaseUid.isNotEmpty ? firebaseUid : uuid;
        if (targetDocId.isEmpty) continue;

        final docRef = _firestore.collection('astrologers').doc(targetDocId);
        
        // Map fields to match the required Firestore schema
        final firestoreData = {
          'name': astro['name'] ?? '',
          'avatarUrl': astro['avatar_url'] ?? '',
          'bio': astro['bio'] ?? '',
          'specialties': List<String>.from(astro['skills'] ?? astro['categories'] ?? []),
          'languages': List<String>.from(astro['languages'] ?? []),
          'pricingPerMinute': (astro['price_per_minute'] as num?)?.toDouble() ?? 0.0,
          'chatRate': (astro['chat_rate'] as num?)?.toDouble() ?? 5.0,
          'callRate': (astro['call_rate'] as num?)?.toDouble() ?? 10.0,
          'videoRate': (astro['video_rate'] as num?)?.toDouble() ?? 15.0,
          'isOnline': astro['is_online'] ?? false,
          'totalConsultations': (astro['reviews_count'] as num?)?.toInt() ?? 0,
          'averageRating': (astro['rating'] as num?)?.toDouble() ?? 5.0,
          'createdAt': astro['created_at'] != null 
              ? Timestamp.fromDate(DateTime.parse(astro['created_at'].toString()))
              : FieldValue.serverTimestamp(),
          'firebase_uid': firebaseUid,
          'astrologer_id': uuid,
        };

        batch.set(docRef, firestoreData, SetOptions(merge: true));
        operationCount++;
        
        // Write in batches of 100 to avoid Firestore limits (max 500)
        if (operationCount >= 100) {
          await batch.commit();
          operationCount = 0;
        }
      }

      // Commit any remaining operations
      if (operationCount > 0) {
        await batch.commit();
      }

      debugPrint('[FirestoreSyncHelper] Successfully synchronized ${astrologers.length} astrologers to Firestore.');
    } catch (e) {
      debugPrint('[FirestoreSyncHelper] Sync error: $e');
    }
  }
}
