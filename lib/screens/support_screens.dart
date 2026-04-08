import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SupportScreen extends StatelessWidget {
  final String title;

  const SupportScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: April 8, 2026',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 32),
            ..._buildContent(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    if (title.toLowerCase().contains('privacy')) {
      return _buildPrivacyPolicy(context);
    } else if (title.toLowerCase().contains('terms')) {
      return _buildTermsOfService(context);
    } else if (title.toLowerCase().contains('help')) {
      return _buildHelpCenter(context);
    }
    return [const Text('Content not found.')];
  }

  List<Widget> _buildPrivacyPolicy(BuildContext context) {
    return [
      _buildSection(context, '1. Data Sovereignty & Offline Storage', 'At Laune, we believe your emotional data is intimately yours. All entries, moods, notes, and tags are stored strictly offline on your local device. We do not maintain any cloud servers, databases, or analytics engines. Your reflections never leave your phone.'),
      const SizedBox(height: 24),
      _buildSection(context, '2. Biometric Authentication', 'When you enable Biometric Lock, Laune delegates authentication entirely to your device\'s native secure enclave (FaceID or TouchID). Laune never captures, stores, or processes your fingerprint or facial geometry data.'),
      const SizedBox(height: 24),
      _buildSection(context, '3. No Analytics & No Tracking', 'We do not embed third-party crashlytics, telemetry tracking, or ad networks. Your usage remains completely anonymous and untracked.'),
      const SizedBox(height: 24),
      _buildSection(context, '4. Contact the Data Controller', 'Since no data is transmitted to us, there is no remote data for us to delete upon request. However, for any privacy inquiries or application feedback, you may instantly reach our developer at oracle.mel02@proton.me.'),
    ];
  }

  List<Widget> _buildTermsOfService(BuildContext context) {
    return [
      _buildSection(context, '1. Application Purpose', 'Laune is provided as a personal journaling and mood reflection tool. It is not intended to substitute professional medical advice, psychological therapy, or psychiatric diagnosis. Always seek the advice of qualified mental health providers with questions regarding a medical condition.'),
      const SizedBox(height: 24),
      _buildSection(context, '2. "As Is" Warranty', 'This application is provided "As Is" without warranties of any kind. Since Laune is a strictly offline application, we are completely unable to recover your encrypted journal entries if you lose your phone, uninstall the app, or forget your PIN code. You assume all responsibility for backing up your device.'),
      const SizedBox(height: 24),
      _buildSection(context, '3. User Liability', 'You are solely responsible for securing your device and the PIN used to restrict access to your journal. Laune shall not be liable for unauthorized access resulting from compromised device security.'),
      const SizedBox(height: 24),
      _buildSection(context, '4. Contact the Developer', 'For legal inquiries or clarifications on these terms, please contact our legal representative at oracle.mel02@proton.me.'),
    ];
  }

  List<Widget> _buildHelpCenter(BuildContext context) {
    return [
      _buildSection(context, 'Welcome to the Oracle Help Center', 'Find answers to common questions about your journey with Laune.'),
      const SizedBox(height: 32),
      _buildSection(context, 'How do Streaks work?', 'Your daily streak increases if you log an entry on consecutive calendar days. If you miss an entire day (from midnight to midnight), your streak resets to zero. Keeping a streak helps build mindfulness habits!'),
      const SizedBox(height: 24),
      _buildSection(context, 'I forgot my PIN. How do I reset it?', 'Because Laune prioritizes extreme privacy, your PIN acts as a local cryptographic barrier. We have NO cloud servers, which means there is no "Forgot Password" email link. If you forget your PIN and do not have Biometrics enabled, you must completely uninstall and reinstall the app, which will permanently delete your previous entries. Please keep your PIN safe.'),
      const SizedBox(height: 24),
      _buildSection(context, 'Does the app log my location?', 'No. Laune does not request, track, or utilize GPS or location services in any capacity.'),
      const SizedBox(height: 24),
      _buildSection(context, 'Still need help?', 'If you’ve encountered a technical bug or want to request a new feature, our engineering team is eager to listen. Please email oracle.mel02@proton.me directly with a description of your issue.'),
    ];
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
