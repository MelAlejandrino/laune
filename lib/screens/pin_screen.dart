import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stitch/main.dart';
import 'package:stitch/theme/app_theme.dart';

enum PinMode { set, confirm, unlock }

class PinScreen extends StatefulWidget {
  final bool isReset;
  const PinScreen({super.key, this.isReset = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  PinMode _mode = PinMode.unlock;
  String _enteredPin = '';
  String _firstPin = ''; // Used for confirmation
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeMode());
  }

  void _initializeMode() {
    final authRepo = MoodScope.of(context).authRepository;
    if (!authRepo.hasPin || widget.isReset) {
      setState(() => _mode = PinMode.set);
    } else {
      setState(() => _mode = PinMode.unlock);
      _checkBiometrics();
    }
  }

  Future<void> _checkBiometrics() async {
    final authRepo = MoodScope.of(context).authRepository;
    if (authRepo.isBiometricEnabled) {
      final success = await authRepo.authenticateBiometrically();
      if (success) _navigateToHome();
    }
  }

  void _onDigitPress(String digit) {
    if (_enteredPin.length >= 4) return;
    
    setState(() {
      _enteredPin += digit;
      _error = '';
    });

    if (_enteredPin.length == 4) {
      _processPin();
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  Future<void> _processPin() async {
    final authRepo = MoodScope.of(context).authRepository;

    if (_mode == PinMode.set) {
      _firstPin = _enteredPin;
      setState(() {
        _enteredPin = '';
        _mode = PinMode.confirm;
      });
    } else if (_mode == PinMode.confirm) {
      if (_enteredPin == _firstPin) {
        await authRepo.setPin(_enteredPin);
        _navigateToHome();
      } else {
        setState(() {
          _enteredPin = '';
          _error = 'PINs do not match. Try again.';
          _mode = PinMode.set;
        });
      }
    } else {
      if (_enteredPin == authRepo.pin) {
        authRepo.authenticate();
        _navigateToHome();
      } else {
        setState(() {
          _enteredPin = '';
          _error = 'Incorrect PIN';
        });
      }
    }
  }

  void _navigateToHome() {
    final authRepo = MoodScope.of(context).authRepository;
    if (authRepo.userName == null) {
      context.go('/setup-name');
    } else {
      context.go('/');
    }
  }

  String get _title {
    switch (_mode) {
      case PinMode.set: return 'Create PIN';
      case PinMode.confirm: return 'Confirm PIN';
      case PinMode.unlock: return 'Unlock Laune';
    }
  }

  String get _subtitle {
    switch (_mode) {
      case PinMode.set: return 'Protect your mindful journey with a 4-digit safety code.';
      case PinMode.confirm: return 'Please repeat the PIN to confirm your identity.';
      case PinMode.unlock: return 'Enter your PIN to enter your sanctuary.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            _buildHeader(context),
            const SizedBox(height: 48),
            _buildPinIndicator(context),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_error, style: TextStyle(color: scheme.error, fontWeight: FontWeight.bold)),
            ],
            const Spacer(flex: 1),
            _buildKeypad(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_person, size: 40, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 32),
          Text(_title, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(_subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPinIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Theme.of(context).colorScheme.primary : Colors.transparent,
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad(BuildContext context) {
    final authRepo = MoodScope.of(context).authRepository;
    final showBiometricIcon = _mode == PinMode.unlock && authRepo.isBiometricEnabled;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['1', '2', '3'].map((d) => _buildKey(context, d)).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['4', '5', '6'].map((d) => _buildKey(context, d)).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['7', '8', '9'].map((d) => _buildKey(context, d)).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSpecialKey(
                context, 
                Icons.fingerprint, 
                showBiometricIcon ? _checkBiometrics : null, 
                isVisible: showBiometricIcon
              ),
              _buildKey(context, '0'),
              _buildSpecialKey(context, Icons.backspace_outlined, _onDelete, isVisible: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(BuildContext context, String digit) {
    return GestureDetector(
      onTap: () => _onDigitPress(digit),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(BuildContext context, IconData icon, VoidCallback? onTap, {required bool isVisible}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        alignment: Alignment.center,
        child: isVisible 
          ? Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary) 
          : const SizedBox.shrink(),
      ),
    );
  }
}
