// 🧬 NEURONVAULT - MAIN APPLICATION ENTRY POINT - CORRECTED
// Real AI Orchestration with Riverpod State Management
// Uses existing NeuronVaultTheme system

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'core/providers/providers_main.dart';
import 'core/theme/app_theme.dart'; // Uses existing NeuronVaultTheme
import 'screens/orchestration_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🖥️ Desktop window configuration
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await windowManager.setTitle('NeuronVault - AI Orchestration Platform');
    await windowManager.setMinimumSize(const Size(800, 600));
    await windowManager.setSize(const Size(1200, 800));
    await windowManager.center();
  }

  // 💾 Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // 🎨 Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1B23),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 🚀 Run application with Riverpod
  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider with actual instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const NeuronVaultApp(),
    ),
  );
}

class NeuronVaultApp extends ConsumerWidget {
  const NeuronVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme state using existing theme system
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'NeuronVault - AI Orchestration Platform',
      debugShowCheckedModeBanner: false,

      // 🎨 Use existing NeuronVaultTheme system
      theme: NeuronVaultTheme.lightTheme,
      darkTheme: NeuronVaultTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // 🏠 Home screen with initialization handling
      home: const InitializationWrapper(),

      // 🌍 App configuration
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Prevent system text scaling
          ),
          child: child!,
        );
      },
    );
  }
}

/// Wrapper to handle app initialization
class InitializationWrapper extends ConsumerWidget {
  const InitializationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializationAsync = ref.watch(initializationProvider);

    return initializationAsync.when(
      // Loading state
      loading: () => const InitializationLoadingScreen(),

      // Error state
      error: (error, stackTrace) => InitializationErrorScreen(
        error: error,
        onRetry: () => ref.invalidate(initializationProvider),
      ),

      // Success state
      data: (initialized) {
        if (initialized) {
          return const OrchestrationMainScreen();
        } else {
          return InitializationErrorScreen(
            error: 'Initialization failed',
            onRetry: () => ref.invalidate(initializationProvider),
          );
        }
      },
    );
  }
}

/// Loading screen during initialization
class InitializationLoadingScreen extends StatefulWidget {
  const InitializationLoadingScreen({super.key});

  @override
  State<InitializationLoadingScreen> createState() => _InitializationLoadingScreenState();
}

class _InitializationLoadingScreenState extends State<InitializationLoadingScreen>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo using existing NeuronColors
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            NeuronColors.primary,
                            NeuronColors.brainBlue,
                            NeuronColors.primaryVariant,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NeuronColors.primary.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // App title using existing typography
            Text(
              'NeuronVault',
              style: NeuronTypography.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'AI Orchestration Platform',
              style: NeuronTypography.textTheme.titleMedium?.copyWith(
                color: Colors.grey[400],
              ),
            ),

            const SizedBox(height: 40),

            // Loading indicator using existing colors
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(NeuronColors.primary),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Initializing AI Orchestration...',
              style: NeuronTypography.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Connecting to backend services',
              style: NeuronTypography.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen for initialization failures
class InitializationErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const InitializationErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon using existing colors
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NeuronColors.error.withOpacity(0.2),
                  border: Border.all(color: NeuronColors.error, width: 2),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: NeuronColors.error,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Initialization Failed',
                style: NeuronTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Failed to initialize the AI orchestration system.',
                style: NeuronTypography.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Error: $error',
                style: NeuronTypography.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Action buttons using existing colors
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NeuronColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  OutlinedButton.icon(
                    onPressed: () {
                      // Show detailed error information
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error Details'),
                          content: SingleChildScrollView(
                            child: Text(error.toString()),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                      side: BorderSide(color: Colors.grey[600]!),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Troubleshooting tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800]?.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(NeuronRadius.md),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting:',
                      style: NeuronTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Ensure the Node.js backend server is running\n'
                          '• Check that port 3001 is available\n'
                          '• Verify network connectivity\n'
                          '• Check browser console for additional errors',
                      style: NeuronTypography.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}