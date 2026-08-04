import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../bloc/astrologer_dashboard_bloc.dart';
import '../bloc/astrologer_dashboard_state.dart';

class AstrologerConsultationHistoryPage extends StatefulWidget {
  const AstrologerConsultationHistoryPage({super.key});

  @override
  State<AstrologerConsultationHistoryPage> createState() => _AstrologerConsultationHistoryPageState();
}

class _AstrologerConsultationHistoryPageState extends State<AstrologerConsultationHistoryPage> {
  String _filter = 'All'; // All, Chat, Call, Video
  Future<List<Map<String, dynamic>>>? _historyFuture;
  String? _lastAstroId;

  Future<List<Map<String, dynamic>>> _fetchHistory(String astrologerId, String firebaseUid) async {
    try {
      final supabase = Supabase.instance.client;
      // 1. Fetch consultations using either Supabase ID or Firebase UID to support legacy records
      var query = supabase.from('consultations').select('*');
      if (firebaseUid.isNotEmpty && firebaseUid != astrologerId) {
        query = query.or('astrologer_id.eq.$astrologerId,astrologer_id.eq.$firebaseUid');
      } else {
        query = query.eq('astrologer_id', astrologerId);
      }
      
      final res = await query.order('created_at', ascending: false);
      final list = List<Map<String, dynamic>>.from(res ?? []);
      if (list.isEmpty) return list;

      // 2. Fetch earnings separately to avoid PostgREST relationship join issues
      final consultationIds = list.map((c) => c['id']?.toString()).where((id) => id != null).toList();
      Map<String, dynamic> earningsMap = {};
      if (consultationIds.isNotEmpty) {
        try {
          final earningsRes = await supabase
              .from('astrologer_earnings')
              .select('consultation_id, net_amount')
              .inFilter('consultation_id', consultationIds);
          for (var earn in earningsRes ?? []) {
            earningsMap[earn['consultation_id']?.toString() ?? ''] = earn;
          }
        } catch (e) {
          debugPrint('[AstrologerConsultationHistoryPage] Earnings fetch error: $e');
        }
      }

      // 3. Collect unique user IDs
      final userIds = list
          .map((c) => c['user_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      if (userIds.isNotEmpty) {
        // 4. Batch fetch profiles from profiles table
        final profilesRes = await supabase
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', userIds);

        final profileMap = {
          for (var p in profilesRes ?? []) p['id']?.toString(): p
        };

        // 5. Merge profiles and earnings into the consultations list
        for (var cons in list) {
          final uId = cons['user_id']?.toString();
          if (uId != null) {
            cons['profiles'] = profileMap[uId];
          }
          final cId = cons['id']?.toString();
          cons['astrologer_earnings'] = earningsMap[cId];
        }
      } else {
        for (var cons in list) {
          final cId = cons['id']?.toString();
          cons['astrologer_earnings'] = earningsMap[cId];
        }
      }

      debugPrint('[AstrologerConsultationHistoryPage] Merged Result: $list');
      return list;
    } catch (e) {
      debugPrint('[AstrologerConsultationHistoryPage] Error fetching history: $e');
      rethrow;
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return '';
    }
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0m';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String _formatEarnings(dynamic earningsData) {
    double netAmount = 0.0;
    if (earningsData is Map) {
      netAmount = (earningsData['net_amount'] as num?)?.toDouble() ?? 0.0;
    } else if (earningsData is List && earningsData.isNotEmpty) {
      netAmount = (earningsData[0]['net_amount'] as num?)?.toDouble() ?? 0.0;
    }
    return '₹${netAmount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    const accentGold = Color(0xFFD4AF37);

    return BlocBuilder<AstrologerDashboardBloc, AstrologerDashboardState>(
      builder: (context, state) {
        if (state is! AstrologerDashboardLoaded) {
          return const Center(child: CircularProgressIndicator(color: accentGold));
        }

        if (_lastAstroId != state.astrologerId) {
          _lastAstroId = state.astrologerId;
          _historyFuture = _fetchHistory(state.astrologerId, state.firebaseUid);
        }

        return Column(
          children: [
            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: ['All', 'Chat', 'Call', 'Video'].map((type) {
                  final isActive = _filter == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isActive,
                      selectedColor: accentGold,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: isActive ? accentGold : const Color(0xFFEFEFEF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      checkmarkColor: Colors.white,
                      onSelected: (_) => setState(() => _filter = type),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Consultation list
            Expanded(
              child: RefreshIndicator(
                color: accentGold,
                onRefresh: () async {
                  setState(() {
                    _historyFuture = _fetchHistory(state.astrologerId, state.firebaseUid);
                  });
                },
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: accentGold));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading history: ${snapshot.error}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }

                    final allRecords = snapshot.data ?? [];
                    final filteredRecords = allRecords.where((cons) {
                      final type = cons['type']?.toString() ?? 'Chat';
                      if (_filter == 'All') return true;
                      if (_filter == 'Call') {
                        return type.toLowerCase().contains('call') && !type.toLowerCase().contains('video');
                      }
                      if (_filter == 'Video') {
                        return type.toLowerCase().contains('video');
                      }
                      return type.toLowerCase() == _filter.toLowerCase();
                    }).toList();

                    if (filteredRecords.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(FontAwesomeIcons.clockRotateLeft, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                const Text(
                                  'No consultation history found',
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return AnimationLimiter(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredRecords.length,
                        itemBuilder: (context, index) {
                          final cons = filteredRecords[index];
                          final profileData = cons['profiles'];
                          Map<String, dynamic>? profile;
                          if (profileData is Map) {
                            profile = Map<String, dynamic>.from(profileData);
                          } else if (profileData is List && profileData.isNotEmpty) {
                            profile = Map<String, dynamic>.from(profileData[0]);
                          }
                          final userName = profile?['full_name'] ?? 'User';
                          final userAvatar = profile?['avatar_url']?.toString();
                          final type = cons['type']?.toString() ?? 'Chat';
                          final durationSeconds = (cons['duration_seconds'] as num?)?.toInt() ?? 0;
                          final startedAt = cons['started_at']?.toString();

                          FaIconData typeIcon;
                          Color typeColor;
                           switch (type.toLowerCase()) {
                            case 'call':
                            case 'audio call':
                              typeIcon = FontAwesomeIcons.phone;
                              typeColor = const Color(0xFF059669);
                              break;
                            case 'video':
                            case 'video call':
                              typeIcon = FontAwesomeIcons.video;
                              typeColor = const Color(0xFFD97706);
                              break;
                            default:
                              typeIcon = FontAwesomeIcons.solidComment;
                              typeColor = const Color(0xFF0EA5E9);
                          }

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(0xFFFDF6EC),
                                        backgroundImage: (userAvatar != null && userAvatar.isNotEmpty)
                                            ? NetworkImage(userAvatar)
                                            : null,
                                        child: (userAvatar == null || userAvatar.isEmpty)
                                            ? Text(
                                                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                                style: const TextStyle(
                                                  color: accentGold,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    userName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  _formatDateTime(startedAt),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: typeColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      FaIcon(typeIcon, color: typeColor, size: 10),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        type,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                          color: typeColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Duration: ${_formatDuration(durationSeconds)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Net Earning:',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  _formatEarnings(cons['astrologer_earnings']),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: accentGold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
