import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:urja/core/shared_widgets/password_field.dart';
import 'package:urja/core/shared_widgets/text_field.dart'; 

// Import your newly created Auth Notifier
import '../notifiers/auth_notifier.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // 1. Basic frontend validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    // Call the notifier — on success, authStateProvider emits the new user,
    // the FSM re-evaluates, and GoRouter redirects automatically.
    await ref.read(authControllerProvider.notifier).signup(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  Future<void> _handleGoogleSignup() async {
    await ref.read(authControllerProvider.notifier).googleLogin();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // 1. WATCH THE STATE
    final authState = ref.watch(authControllerProvider);
    final bool isLoading = authState.isLoading; 

    // 2. LISTEN FOR ERRORS
    ref.listen<AuthFormState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withAlpha((255 * 0.1).toInt()),
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Lottie.asset('assets/lottie/truck.json', height: 180),
                  const Icon(Icons.eco, size: 80, color: Colors.green), // Urja theme icon
                  const SizedBox(height: 24),
                  
                  Text(
                    "Join Urja",
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    "Create an account to power your colony", 
                    textAlign: TextAlign.center, 
                    style: textTheme.titleMedium
                  ),
                  const SizedBox(height: 32),

                  UrjaTextField(
                    hintText: "Full Name",
                    icon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  
                  UrjaTextField(
                    hintText: "Email Address",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  
                  UrjaPasswordField(
                    controller: _passwordController,
                    hintText: "Password",
                  ),
                  const SizedBox(height: 16),

                  UrjaPasswordField(
                    controller: _confirmPasswordController,
                    hintText: "Confirm Password",
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSignup,
                      child: isLoading
                          ? const SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                            )
                          : const Text("Sign Up"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text("OR", style: theme.textTheme.bodySmall),
                      ),
                      Expanded(child: Divider(color: theme.dividerColor)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : _handleGoogleSignup,
                      icon: const Icon(Icons.g_mobiledata, size: 30),
                      label: const Text("Sign up with Google"),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Navigation back to Login ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?", style: textTheme.bodyMedium),
                      TextButton(
                        onPressed: isLoading ? null : () => context.go('/login'),
                        child: Text(
                          "Login",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}