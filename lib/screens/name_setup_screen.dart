import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stitch/main.dart';
import 'package:stitch/theme/app_theme.dart';

class NameSetupScreen extends StatefulWidget {
  const NameSetupScreen({super.key});

  @override
  State<NameSetupScreen> createState() => _NameSetupScreenState();
}

class _NameSetupScreenState extends State<NameSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() => _isValid = _nameController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_isValid) return;
    
    final authRepo = MoodScope.of(context).authRepository;
    await authRepo.setUserName(_nameController.text.trim());
    
    if (mounted) {
      context.go('/terms-accept');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              _buildIcon(context),
              const SizedBox(height: 48),
              Text(
                'What should we call you?',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Personalize your sanctuary with your name.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 48),
              _buildNameField(context),
              const Spacer(),
              _buildContinueButton(context),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.face_retouching_natural_outlined,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _nameController,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      onSubmitted: (_) => _onContinue(),
      decoration: InputDecoration(
        hintText: 'Your name',
        hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: scheme.onSurfaceVariant.withOpacity(0.2),
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.1), width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isValid ? _onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withOpacity(0.05),
          disabledForegroundColor: scheme.onSurface.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          elevation: _isValid ? 8 : 0,
          shadowColor: scheme.primary.withOpacity(0.4),
        ),
        child: const Text(
          'CONTINUE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
