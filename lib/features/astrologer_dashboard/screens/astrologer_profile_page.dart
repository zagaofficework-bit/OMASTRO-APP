import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/astrologer_dashboard_bloc.dart';
import '../bloc/astrologer_dashboard_state.dart';
import '../../../core/services/presence_service.dart';

class AstrologerDashboardProfilePage extends StatelessWidget {
  const AstrologerDashboardProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const accentGold = Color(0xFFD4AF37);

    return BlocBuilder<AstrologerDashboardBloc, AstrologerDashboardState>(
      builder: (context, state) {
        if (state is! AstrologerDashboardLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar + Name
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (state.avatarUrl != null && state.avatarUrl!.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => Dialog(
                              backgroundColor: Colors.black,
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  InteractiveViewer(
                                    child: Image.network(state.avatarUrl!, fit: BoxFit.contain),
                                  ),
                                  Positioned(
                                    top: 40,
                                    left: 20,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                          onPressed: () => Navigator.pop(dialogCtx),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          state.name,
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFFDF6EC),
                        backgroundImage: state.avatarUrl != null ? NetworkImage(state.avatarUrl!) : null,
                        child: state.avatarUrl == null
                            ? Text(
                                state.name.isNotEmpty ? state.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: accentGold),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.experienceYears} Years Experience',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    // Rating + Reviews
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: accentGold, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          state.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${state.reviewsCount} reviews)',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/astrologer-edit-profile'),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: accentGold),
                      label: const Text(
                        'Edit Profile Details',
                        style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: accentGold, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Rates
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.currency_rupee, size: 18, color: accentGold),
                        SizedBox(width: 8),
                        Text('Consulting Rates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _rateRow('💬 Chat', '₹${state.chatRate.toStringAsFixed(0)}/msg'),
                    _rateRow('📞 Call', '₹${state.callRate.toStringAsFixed(0)}/min'),
                    _rateRow('🎥 Video', '₹${state.videoRate.toStringAsFixed(0)}/min'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: accentGold),
                        SizedBox(width: 8),
                        Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _detailRow('Languages', state.languages.join(', ')),
                    _detailRow('Skills', state.skills.join(', ')),
                    _detailRow('Categories', state.categories.join(', ')),
                    _detailRow('Consulted', '${state.totalMinutesConsulted} minutes'),
                    if (state.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Bio', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(state.bio, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black54)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sign Out
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final dashState = context.read<AstrologerDashboardBloc>().state;
                    if (dashState is AstrologerDashboardLoaded) {
                      await PresenceService().setPresence(
                        firebaseUid: dashState.firebaseUid,
                        astrologerId: dashState.astrologerId,
                        isOnline: false,
                      );
                    }
                    globalAuthBloc.add(SignOutRequested());
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Sign Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _rateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
