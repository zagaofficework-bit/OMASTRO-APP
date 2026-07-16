import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/astrologer_dashboard_bloc.dart';
import '../bloc/astrologer_dashboard_state.dart';
import '../bloc/astrologer_dashboard_event.dart';

class AstrologerDashboardPage extends StatelessWidget {
  const AstrologerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const accentGold = Color(0xFFD4AF37);

    return BlocBuilder<AstrologerDashboardBloc, AstrologerDashboardState>(
      builder: (context, state) {
        if (state is AstrologerDashboardLoading) {
          return const Center(child: CircularProgressIndicator(color: accentGold));
        }
        if (state is! AstrologerDashboardLoaded) {
          return const Center(child: Text('Loading dashboard...'));
        }

        return RefreshIndicator(
          color: accentGold,
          onRefresh: () async {
            if (state is AstrologerDashboardLoaded) {
              final loadedState = state as AstrologerDashboardLoaded;
              context.read<AstrologerDashboardBloc>().add(
                LoadAstrologerDashboard(
                  astrologerId: loadedState.astrologerId,
                  firebaseUid: loadedState.firebaseUid,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Greeting
              Text(
                'Welcome, ${state.name} 🙏',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.isOnline ? '🟢 You are currently online' : '⚫ You are currently offline',
                style: TextStyle(
                  fontSize: 13,
                  color: state.isOnline ? const Color(0xFF10B981) : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Stats Cards Row
              Row(
                children: [
                  Expanded(child: _statCard('⭐', 'Rating', state.rating.toStringAsFixed(1), const Color(0xFFFDF6EC))),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('💬', 'Reviews', state.reviewsCount.toString(), const Color(0xFFF0FDF4))),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('🕐', 'Minutes', state.totalMinutesConsulted.toString(), const Color(0xFFF0F9FF))),
                ],
              ),
              const SizedBox(height: 24),

              // Rates Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.currency_rupee, size: 18, color: accentGold),
                        SizedBox(width: 8),
                        Text('Your Rates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _rateChip('💬 Chat', '₹${state.chatRate.toStringAsFixed(0)}/msg')),
                        const SizedBox(width: 8),
                        Expanded(child: _rateChip('📞 Call', '₹${state.callRate.toStringAsFixed(0)}/min')),
                        const SizedBox(width: 8),
                        Expanded(child: _rateChip('🎥 Video', '₹${state.videoRate.toStringAsFixed(0)}/min')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_outline, size: 18, color: accentGold),
                        SizedBox(width: 8),
                        Text('Profile Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow('Experience', '${state.experienceYears} Years'),
                    _infoRow('Languages', state.languages.join(', ')),
                    _infoRow('Skills', state.skills.join(', ')),
                    _infoRow('Categories', state.categories.join(', ')),
                    if (state.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.bio,
                        style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _statCard(String emoji, String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _rateChip(String label, String rate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(rate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
