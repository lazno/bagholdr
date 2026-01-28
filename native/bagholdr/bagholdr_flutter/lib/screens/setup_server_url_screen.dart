import 'package:flutter/material.dart';

import '../main.dart';
import '../services/app_settings.dart';
import 'app_shell.dart';

/// Setup screen shown on first launch for production builds.
///
/// Prompts user to enter their server URL before using the app.
/// After setup, initializes the client and navigates to the main app.
class SetupServerUrlScreen extends StatefulWidget {
  const SetupServerUrlScreen({super.key});

  @override
  State<SetupServerUrlScreen> createState() => _SetupServerUrlScreenState();
}

class _SetupServerUrlScreenState extends State<SetupServerUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  String? _validationError;
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final url = _urlController.text.trim();

    // Validate URL
    final error = AppSettings.validateServerUrl(url);
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }

    setState(() {
      _validationError = null;
      _isLoading = true;
    });

    // Ensure URL ends with /
    final normalizedUrl = url.endsWith('/') ? url : '$url/';

    // Save the URL
    final success = await AppSettings.setCustomServerUrl(normalizedUrl);

    if (!mounted) return;

    if (!success) {
      setState(() {
        _isLoading = false;
        _validationError = 'Failed to save URL';
      });
      return;
    }

    // Initialize the client with the new URL
    initializeClient(normalizedUrl);

    // Navigate to main app (replace so user can't go back)
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // App icon/logo
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  // App name
                  Text(
                    'Bagholdr',
                    style: textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Portfolio Tracking',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Instructions
                  Text(
                    'Enter your server URL',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect to your Bagholdr server to get started.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // URL input
                  TextFormField(
                    controller: _urlController,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'https://bagholdr.example.com/',
                      errorText: _validationError,
                      prefixIcon: const Icon(Icons.dns_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _onContinue(),
                    onChanged: (_) {
                      if (_validationError != null) {
                        setState(() => _validationError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // Continue button
                  FilledButton(
                    onPressed: _isLoading ? null : _onContinue,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue'),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
