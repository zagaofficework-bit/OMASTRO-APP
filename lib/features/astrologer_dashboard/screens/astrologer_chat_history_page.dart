import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/astrologer_dashboard_bloc.dart';
import '../bloc/astrologer_dashboard_state.dart';
import '../../chat/screens/chat_room_page.dart';

class AstrologerChatHistoryPage extends StatelessWidget {
  const AstrologerChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AstrologerDashboardBloc, AstrologerDashboardState>(
      builder: (context, state) {
        if (state is! AstrologerDashboardLoaded) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('members', arrayContains: state.firebaseUid)
              .orderBy('lastMessageAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(FontAwesomeIcons.solidMessage, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text('No chat history yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Your conversations will appear here', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              );
            }

            return AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final memberNames = data['memberNames'] as Map<String, dynamic>? ?? {};
                  final memberAvatars = data['memberAvatars'] as Map<String, dynamic>? ?? {};
                  final members = List<String>.from(data['members'] ?? []);
                  final otherUid = members.firstWhere((id) => id != state.firebaseUid, orElse: () => '');
                  final userName = memberNames[otherUid] ?? 'Unknown User';
                  final userAvatarUrl = memberAvatars[otherUid]?.toString();
                  final lastMessage = data['lastMessage'] as String? ?? '';
                  final lastMessageAt = data['lastMessageAt'] as Timestamp?;
                  final astrologerId = data['astrologerId'] as String? ?? '';

                  final unreadMap = data['unread'] as Map<String, dynamic>? ?? {};
                  final unreadCount = ((unreadMap[state.firebaseUid] ?? unreadMap[state.astrologerId]) as num?)?.toInt() ?? 0;

                  String timeStr = '';
                  if (lastMessageAt != null) {
                    final date = lastMessageAt.toDate();
                    final now = DateTime.now();
                    if (date.year == now.year && date.month == now.month && date.day == now.day) {
                      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
                      final minute = date.minute.toString().padLeft(2, '0');
                      final period = date.hour >= 12 ? 'PM' : 'AM';
                      timeStr = '$hour:$minute $period';
                    } else {
                      timeStr = '${date.day}/${date.month}/${date.year}';
                    }
                  }

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                context.push('/chat-room', extra: {
                                  'id': astrologerId,
                                  'name': userName,
                                  'otherUid': otherUid,
                                  'avatarUrl': userAvatarUrl ?? '',
                                });
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: (userAvatarUrl != null && userAvatarUrl.isNotEmpty)
                                    ? CircleAvatar(
                                        backgroundColor: const Color(0xFFFDF6EC),
                                        backgroundImage: NetworkImage(userAvatarUrl),
                                      )
                                    : FutureBuilder<String?>(
                                        future: () async {
                                          try {
                                            final res = await Supabase.instance.client
                                                .from('profiles')
                                                .select('avatar_url')
                                                .eq('id', otherUid)
                                                .maybeSingle();
                                            return res?['avatar_url']?.toString();
                                          } catch (_) {
                                            return null;
                                          }
                                        }(),
                                        builder: (context, snapshot) {
                                          final url = snapshot.data;
                                          return CircleAvatar(
                                            backgroundColor: const Color(0xFFFDF6EC),
                                            backgroundImage: (url != null && url.isNotEmpty)
                                                ? NetworkImage(url)
                                                : null,
                                            child: (url == null || url.isEmpty)
                                                ? Text(
                                                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                                    style: const TextStyle(
                                                      color: Color(0xFFD4AF37),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                : null,
                                          );
                                        },
                                      ),
                                title: Text(
                                  userName,
                                  style: TextStyle(
                                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: unreadCount > 0 ? Colors.black87 : Colors.grey,
                                    fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      timeStr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: unreadCount > 0 ? const Color(0xFFD4AF37) : Colors.grey,
                                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    if (unreadCount > 0) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
