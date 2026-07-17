import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ConsultationHistoryPage extends StatefulWidget {
  const ConsultationHistoryPage({super.key});

  @override
  State<ConsultationHistoryPage> createState() => _ConsultationHistoryPageState();
}

class _ConsultationHistoryPageState extends State<ConsultationHistoryPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Check user role from global AuthBloc state
      final authState = context.read<AuthBloc>().state;
      final bool isAstrologer = authState is AuthenticatedAsAstrologer ||
          authState is AstrologerOnboardingRequired;

      List<dynamic> consRes = [];
      if (isAstrologer) {
        // Query as astrologer (join with user_id profile to show the client's name)
        consRes = await _supabase
            .from('consultations')
            .select('*, profiles:user_id(full_name, avatar_url)')
            .eq('astrologer_id', user.id)
            .order('created_at', ascending: false);
      } else {
        // Query as client (join with astrologer_id via astrologers -> profiles to get name and avatar)
        consRes = await _supabase
            .from('consultations')
            .select('*, astrologers:astrologer_id(*, profiles(full_name, avatar_url))')
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
      }

      List<Map<String, dynamic>> mappedHistory = [];

      for (var cons in consRes) {
        String name = 'User';
        String avatarUrl = '';
        
        if (isAstrologer) {
          final profile = cons['profiles'] as Map<String, dynamic>?;
          name = profile?['full_name'] ?? 'Client';
          avatarUrl = profile?['avatar_url'] ?? '';
        } else {
          final astro = cons['astrologers'] as Map<String, dynamic>?;
          name = astro?['name'] ?? 'Astrologer';
          avatarUrl = astro?['avatar_url'] ?? '';
        }

        final String type = cons['type']?.toString() ?? 'Call';
        final int durationSeconds = (cons['duration_seconds'] as num?)?.toInt() ?? 0;
        final String status = cons['status']?.toString() ?? 'Completed';
        
        // Calculate duration display
        String durationStr = '-';
        if (durationSeconds > 0) {
          final mins = durationSeconds ~/ 60;
          final secs = durationSeconds % 60;
          durationStr = mins > 0 ? '${mins}m ${secs}s' : '${secs}s';
        }

        // Format Date
        String formattedDate = '';
        if (cons['created_at'] != null) {
          final date = DateTime.parse(cons['created_at']).toLocal();
          formattedDate = '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        }

        // Get total cost/earnings
        double totalCost = 0.0;
        try {
          // Look up transaction note matching this consultation ID
          final txRes = await _supabase
              .from('wallet_transactions')
              .select('amount_paise')
              .eq('user_id', cons['user_id'] ?? '')
              .ilike('note', '%${cons['id']}%')
              .maybeSingle();
          if (txRes != null && txRes['amount_paise'] != null) {
            totalCost = (txRes['amount_paise'] as num) / 100.0;
          }
        } catch (_) {}

        mappedHistory.add({
          'name': name,
          'type': type[0].toUpperCase() + type.substring(1),
          'duration': durationStr,
          'total': totalCost > 0 ? '₹${totalCost.toStringAsFixed(0)}' : '₹0',
          'date': formattedDate,
          'status': status,
          'image': avatarUrl,
          'raw_astrologer': cons['astrologers'],
        });
      }

      // Fallback: If consultations is empty, populate from transactions for backward compatibility
      if (mappedHistory.isEmpty) {
        if (isAstrologer) {
          // Fallback for Astrologer using transactions where they were mentioned in the note
          final txRes = await _supabase
              .from('wallet_transactions')
              .select()
              .ilike('note', '%${user.id}%')
              .order('created_at', ascending: false);

          final List<Map<String, dynamic>> rawTx = List<Map<String, dynamic>>.from(txRes);
          for (var tx in rawTx) {
            final String note = tx['note'] ?? '';
            String type = 'Call';
            if (note.contains('Chat')) {
              type = 'Chat';
            }

            // Fetch the client's name who made the transaction
            String name = 'Client';
            String avatarUrl = '';
            final clientUid = tx['user_id'] as String?;
            if (clientUid != null) {
              final profileRes = await _supabase
                  .from('profiles')
                  .select('full_name, avatar_url')
                  .eq('id', clientUid)
                  .maybeSingle();
              if (profileRes != null) {
                name = profileRes['full_name'] ?? 'Unknown Client';
                avatarUrl = profileRes['avatar_url'] ?? '';
              }
            }

            final amount = (tx['amount_paise'] as num) / 100.0;
            final date = DateTime.parse(tx['created_at']).toLocal();
            final formattedDate = '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

            mappedHistory.add({
              'name': name,
              'type': type,
              'duration': '-',
              'total': '₹${amount.toStringAsFixed(0)}',
              'date': formattedDate,
              'status': 'Completed',
              'image': avatarUrl,
            });
          }
        } else {
          // Fallback for Client using their own debit transactions
          final txRes = await _supabase
              .from('wallet_transactions')
              .select()
              .eq('user_id', user.id)
              .eq('kind', 'debit')
              .order('created_at', ascending: false);

          final List<Map<String, dynamic>> rawTx = List<Map<String, dynamic>>.from(txRes);
          for (var tx in rawTx) {
            final String note = tx['note'] ?? '';
            String type = 'Chat';
            String astroId = '';

            if (note.contains('Chat message to Astro ID:')) {
              type = 'Chat';
              astroId = note.split('Astro ID:').last.trim();
            } else if (note.contains('Call with Astrologer ID:')) {
              type = 'Call';
              astroId = note.split('Astrologer ID:').last.trim();
            }

            String name = 'Astrologer';
            String avatarUrl = '';
            if (astroId.isNotEmpty) {
              final profileRes = await _supabase
                  .from('profiles')
                  .select('full_name, avatar_url')
                  .eq('id', astroId)
                  .maybeSingle();
              if (profileRes != null) {
                name = profileRes['full_name'] ?? 'Unknown Astrologer';
                avatarUrl = profileRes['avatar_url'] ?? '';
              }
            }

            final amount = (tx['amount_paise'] as num) / 100.0;
            final date = DateTime.parse(tx['created_at']).toLocal();
            final formattedDate = '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

            mappedHistory.add({
              'name': name,
              'type': type,
              'duration': '-',
              'total': '₹${amount.toStringAsFixed(0)}',
              'date': formattedDate,
              'status': 'Completed',
              'image': avatarUrl,
            });
          }
        }
      }

      setState(() {
        _history = mappedHistory;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching consultation history: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    final initials = words
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF9), Color(0xFFF7F2E9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : _history.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final item = _history[index];
                              return _buildHistoryCard(item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              shadowColor: Colors.black.withOpacity(0.04),
              elevation: 4,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Consulting History',
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No History Found',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed consultations will show up here.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final isChat = item['type'] == 'Chat';
    final isVideo = item['type'] == 'Video';
    final isCall = !isChat && !isVideo;

    final typeIcon = isChat
        ? Icons.chat_bubble_rounded
        : (isVideo ? Icons.videocam_rounded : Icons.call_rounded);

    final typeColor = isChat
        ? const Color(0xFF0EA5E9)
        : (isVideo ? const Color(0xFFD97706) : const Color(0xFF059669));

    final String avatarUrl = item['image']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        final astroMap = item['raw_astrologer'] as Map<String, dynamic>?;
        if (astroMap != null) {
          context.push(
            '/astrologer-profile',
            extra: {
              'id': astroMap['id']?.toString() ?? '',
              'firebase_uid': astroMap['firebase_uid']?.toString() ?? '',
              'name': astroMap['name']?.toString() ?? '',
              'imageUrl': astroMap['avatar_url']?.toString() ?? '',
              'specialties': (astroMap['categories'] as List?)?.join(', ') ?? '',
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF1E6D2), // Sleek warm gold border
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withOpacity(0.04), // Ambient warm amber shadow
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Large Avatar & Overlay Icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFFFF9EE),
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            _getInitials(item['name']),
                            style: const TextStyle(
                              color: Color(0xFFD97706),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: typeColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(typeIcon, size: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Middle: Name, Date, Duration & Type Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 5),
                      Text(
                        item['date'],
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 5),
                      Text(
                        '${item['type']} · ${item['duration']}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right: Price tag & Status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['total'],
                  style: const TextStyle(
                    color: Color(0xFF1E1B16),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5), // Modern emerald light background
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFA7F3D0), // Sage emerald border
                      width: 0.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded, 
                        size: 9, 
                        color: Color(0xFF059669),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: Color(0xFF047857),
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
