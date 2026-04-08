import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stitch/main.dart';

class TermsAcceptScreen extends StatelessWidget {
  const TermsAcceptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onCancel(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please read and accept the following terms to continue.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      '1. Application Purpose',
                      'Laune is provided as a personal journaling and mood reflection tool. It is not intended to substitute professional medical advice, psychological therapy, or psychiatric diagnosis. Always seek the advice of qualified mental health providers with questions regarding a medical condition.',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      '2. "As Is" Warranty',
                      'This application is provided "As Is" without warranties of any kind. Since Laune is a strictly offline application, we are completely unable to recover your encrypted journal entries if you lose your phone, uninstall the app, or forget your PIN code. You assume all responsibility for backing up your device.',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      '3. User Liability',
                      'You are solely responsible for securing your device and the PIN used to restrict access to your journal. Laune shall not be liable for unauthorized access resulting from compromised device security.',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      '4. Contact the Developer',
                      'For legal inquiries or clarifications on these terms, please contact our legal representative at oracle.mel02@proton.me.',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _onCancel(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                        side: BorderSide(color: scheme.outline.withOpacity(0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onAgree(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        elevation: 8,
                      ),
                      child: const Text(
                        'AGREE',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAgree(BuildContext context) async {
    final authRepo = MoodScope.of(context).authRepository;
    await authRepo.setTermsAccepted(true);
    if (!context.mounted) return;
    context.go('/setup-reminder');
  }

  void _onCancel(BuildContext context) {
    final authRepo = MoodScope.of(context).authRepository;
    authRepo.logout();
    if (!context.mounted) return;
    context.go('/login');
  }

  Widget _buildSection(BuildContext context, String header, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ],
    );
  }
}

