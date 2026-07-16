import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';

class AstrologerOnboardingPage extends StatefulWidget {
  const AstrologerOnboardingPage({super.key});

  @override
  State<AstrologerOnboardingPage> createState() => _AstrologerOnboardingPageState();
}

class _AstrologerOnboardingPageState extends State<AstrologerOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _chatRateController = TextEditingController(text: '5');
  final _callRateController = TextEditingController(text: '10');
  final _videoRateController = TextEditingController(text: '15');

  List<String> _selectedLanguages = [];
  List<String> _selectedSkills = [];
  List<String> _selectedCategories = [];
  bool _isSubmitting = false;

  static const _allLanguages = ['Hindi', 'English', 'Tamil', 'Telugu', 'Bengali', 'Marathi', 'Gujarati', 'Kannada', 'Malayalam', 'Punjabi'];
  static const _allSkills = ['Vedic Astrology', 'Numerology', 'Tarot', 'Palmistry', 'Vastu', 'KP Astrology', 'Prashna Kundali', 'Face Reading', 'Reiki', 'Feng Shui'];
  static const _allCategories = ['Love', 'Career', 'Finance', 'Health', 'Marriage', 'Family', 'Education', 'Business', 'Legal', 'Spiritual'];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _chatRateController.dispose();
    _callRateController.dispose();
    _videoRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGold = Color(0xFFE5C693);
    const accentGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F0),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFDF6EC), Color(0xFFFFF9F0)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEAE2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: accentGold, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fill in your details and set your consulting rates to start receiving clients.',
                        style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Personal Details Section ──
              _sectionHeader('Personal Details', Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(_nameController, 'Full Name', Icons.badge_outlined, required: true),
              const SizedBox(height: 14),
              _buildTextField(_bioController, 'Bio / About You', Icons.description_outlined, maxLines: 3, required: true),
              const SizedBox(height: 14),
              _buildTextField(
                _experienceController,
                'Experience (Years)',
                Icons.work_history_outlined,
                keyboardType: TextInputType.number,
                required: true,
              ),
              const SizedBox(height: 24),

              // ── Languages ──
              _sectionHeader('Languages You Speak', Icons.language),
              const SizedBox(height: 12),
              _buildChipSelector(
                items: _allLanguages,
                selected: _selectedLanguages,
                onChanged: (val) => setState(() => _selectedLanguages = val),
              ),
              const SizedBox(height: 24),

              // ── Skills ──
              _sectionHeader('Your Skills', Icons.psychology_outlined),
              const SizedBox(height: 12),
              _buildChipSelector(
                items: _allSkills,
                selected: _selectedSkills,
                onChanged: (val) => setState(() => _selectedSkills = val),
              ),
              const SizedBox(height: 24),

              // ── Categories ──
              _sectionHeader('Consultation Categories', Icons.category_outlined),
              const SizedBox(height: 12),
              _buildChipSelector(
                items: _allCategories,
                selected: _selectedCategories,
                onChanged: (val) => setState(() => _selectedCategories = val),
              ),
              const SizedBox(height: 28),

              // ── Consulting Rates Section ──
              _sectionHeader('Set Your Consulting Rates', Icons.currency_rupee),
              const SizedBox(height: 6),
              const Text(
                'These rates will be displayed to users when they connect with you.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildRateField(_chatRateController, '💬 Chat', '₹/msg')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildRateField(_callRateController, '📞 Call', '₹/min')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildRateField(_videoRateController, '🎥 Video', '₹/min')),
                ],
              ),
              const SizedBox(height: 36),

              // ── Submit Button ──
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    disabledBackgroundColor: primaryGold.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                        )
                      : const Text(
                          'Complete Profile & Start',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: required
          ? (val) => (val == null || val.trim().isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.black54, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEFEFEF), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5C693), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRateField(TextEditingController controller, String label, String suffix) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          validator: (val) {
            if (val == null || val.isEmpty) return 'Required';
            final n = double.tryParse(val);
            if (n == null || n <= 0) return 'Invalid';
            return null;
          },
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEFEFEF), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5C693), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipSelector({
    required List<String> items,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected.contains(item);
        return FilterChip(
          label: Text(
            item,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          selectedColor: const Color(0xFFD4AF37),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFEFEFEF),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          checkmarkColor: Colors.white,
          onSelected: (val) {
            final newList = List<String>.from(selected);
            val ? newList.add(item) : newList.remove(item);
            onChanged(newList);
          },
        );
      }).toList(),
    );
  }

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one language')),
      );
      return;
    }
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authState = globalAuthBloc.state;
      String? astrologerId;
      String astroName = _nameController.text.trim();

      if (authState is AstrologerOnboardingRequired) {
        astrologerId = authState.astrologerId;
      }

      if (astrologerId == null) {
        throw Exception('Astrologer ID not found in auth state');
      }

      final chatRate = double.parse(_chatRateController.text.trim());
      final callRate = double.parse(_callRateController.text.trim());
      final videoRate = double.parse(_videoRateController.text.trim());
      final experience = int.tryParse(_experienceController.text.trim()) ?? 0;

      // Update Supabase astrologers table
      await Supabase.instance.client
          .from('astrologers')
          .update({
            'name': astroName,
            'bio': _bioController.text.trim(),
            'experience_years': experience,
            'languages': _selectedLanguages,
            'skills': _selectedSkills,
            'categories': _selectedCategories,
            'chat_rate': chatRate,
            'call_rate': callRate,
            'video_rate': videoRate,
            'price_per_minute': callRate, // Legacy field, use call_rate
          })
          .eq('id', astrologerId);

      // Transition to authenticated astrologer state
      globalAuthBloc.add(AstrologerSignInRequested(
        Supabase.instance.client.auth.currentUser?.email ?? '',
        '', // Re-auth not needed — we just update the state
      ));

      // Navigate to astrologer dashboard
      if (mounted) {
        context.go('/astrologer-home');
      }
    } catch (e) {
      debugPrint('[Onboarding] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
