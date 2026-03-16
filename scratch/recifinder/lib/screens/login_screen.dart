import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepOrange, Colors.orangeAccent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Title
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ReciFinder',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover delicious recipes',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Continue with Email Button
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/email-login'),
                    icon: const Icon(Icons.email, color: Colors.deepOrange),
                    label: Text(
                      'Continue with Email',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Continue with Google Button - only show if Firebase is available
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (!authProvider.firebaseAvailable) {
                        return Container(); // Hide Google sign-in if Firebase not available
                      }

                      return ElevatedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                try {
                                  await authProvider.signInWithGoogle();
                                  if (mounted) {
                                    Navigator.of(context).pushReplacementNamed('/home');
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${e.toString()}')),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                        label: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Continue with Google',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      );
                    },
                  ),

                  // Show message if Firebase is not available
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (!authProvider.firebaseAvailable) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'Note: Firebase authentication is not configured. Only email login is available.',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Terms and Privacy
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
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