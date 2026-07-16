import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/astrologer_dashboard_bloc.dart';
import '../bloc/astrologer_dashboard_state.dart';

class AstrologerConsultationHistoryPage extends StatefulWidget {
  const AstrologerConsultationHistoryPage({super.key});

  @override
  State<AstrologerConsultationHistoryPage> createState() => _AstrologerConsultationHistoryPageState();
}

class _AstrologerConsultationHistoryPageState extends State<AstrologerConsultationHistoryPage> {
  String _filter = 'All'; // All, Chat, Call, Video

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AstrologerDashboardBloc, AstrologerDashboardState>(
      builder: (context, state) {
        if (state is! AstrologerDashboardLoaded) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
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
                      selectedColor: const Color(0xFFD4AF37),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: isActive ? const Color(0xFFD4AF37) : const Color(0xFFEFEFEF)),
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
              child: StreamBuilder<QuerySnapshot>(
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
                          Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text('No consultation history', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final memberNames = data['memberNames'] as Map<String, dynamic>? ?? {};
                      final members = List<String>.from(data['members'] ?? []);
                      final otherUid = members.firstWhere((id) => id != state.firebaseUid, orElse: () => '');
                      final userName = memberNames[otherUid] ?? 'Unknown';
                      final lastMessageAt = data['lastMessageAt'] as Timestamp?;
                      final consultationType = data['consultation_type'] as String? ?? 'Chat';

                      // Apply filter
                      if (_filter != 'All' && consultationType.toLowerCase() != _filter.toLowerCase()) {
                        return const SizedBox.shrink();
                      }

                      String dateStr = '';
                      if (lastMessageAt != null) {
                        final date = lastMessageAt.toDate();
                        dateStr = '${date.day}/${date.month}/${date.year}';
                      }

                      IconData typeIcon;
                      Color typeColor;
                      switch (consultationType.toLowerCase()) {
                        case 'call':
                          typeIcon = Icons.call;
                          typeColor = const Color(0xFF059669);
                          break;
                        case 'video':
                          typeIcon = Icons.videocam;
                          typeColor = const Color(0xFFD97706);
                          break;
                        default:
                          typeIcon = Icons.chat_bubble;
                          typeColor = const Color(0xFF0EA5E9);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(typeIcon, color: typeColor, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                      Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Duration: ${data['duration'] ?? '00:00'}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Rate: ₹${data['rate'] ?? '10'}/min',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                      Text(
                                        '₹${data['earned'] ?? '0'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFFD4AF37), // Gold
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
