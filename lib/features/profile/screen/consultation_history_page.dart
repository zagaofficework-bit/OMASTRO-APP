import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

      // Fetch debit transactions (consultations)
      final txRes = await _supabase
          .from('wallet_transactions')
          .select()
          .eq('user_id', user.id)
          .eq('kind', 'debit')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> rawTx = List<Map<String, dynamic>>.from(txRes);
      List<Map<String, dynamic>> mappedHistory = [];

      for (var tx in rawTx) {
        final String note = tx['note'] ?? '';
        String type = 'Consultation';
        String name = 'Astrologer';
        String astroId = '';

        if (note.contains('Chat message to Astro ID:')) {
          type = 'Chat';
          astroId = note.split('Astro ID:').last.trim();
        } else if (note.contains('Call with Astro ID:')) {
          type = 'Call'; // Can be video or audio, but we'll label as Call
          astroId = note.split('Astro ID:').last.trim();
        }

        // Fetch astrologer profile if astroId exists
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
          'duration': '-', // Derived from tokens or actual duration would be better
          'rate': '-',
          'total': '₹${amount.toStringAsFixed(0)}',
          'date': formattedDate,
          'status': 'Completed',
          'image': avatarUrl,
        });
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('History', style: TextStyle(color: AppColors.textPrimary)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Text(
          'History',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _history.length,
          itemBuilder: (context, index) {
            final item = _history[index];
            final isChat = item['type'] == 'Chat';
            final isVideo = item['type'] == 'Video Call';
            final isCall = !isChat && !isVideo;

            final typeIcon = isChat
                ? Icons.chat_bubble_rounded
                : (isVideo ? Icons.videocam_rounded : Icons.call_rounded);
                
            final typeColor = isChat
                ? const Color(0xFF0EA5E9)
                : (isVideo ? const Color(0xFFD97706) : const Color(0xFF059669));

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with Status Indicator
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.background,
                          backgroundImage: item['image'] != null && item['image'].toString().isNotEmpty
                              ? NetworkImage(item['image']) as ImageProvider
                              : const AssetImage('assets/images/default_avatar.png'),
                          onBackgroundImageError: (_, __) {},
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: typeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(typeIcon, size: 12, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Central Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: AppTextStyles.headingMedium.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              item['date'],
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              '${item['type']} • ${item['duration']}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Trailing Amount and Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['total'],
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.onlineGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['status'],
                          style: TextStyle(
                            color: AppColors.onlineGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
