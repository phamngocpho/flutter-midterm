import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/user_management/presentation/bloc/user_bloc.dart';
import 'features/user_management/presentation/pages/login_page.dart';
import 'injection_container.dart' as di;

import 'core/utils/http_overrides_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Setup HttpOverrides (chỉ hoạt động trên mobile/desktop, không phải web)
  setupHttpOverrides();

  String? initError;
  try {
    await di.init();
  } catch (e) {
    // Don't print error messages, just store the error
    initError = e.toString();
  }

  runApp(MyApp(initError: initError));
}

class MyApp extends StatelessWidget {
  final String? initError;

  const MyApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    // Provide UserBloc at app level so it's available to all routes
    return BlocProvider(
      create: (_) => di.sl<UserBloc>(),
      child: MaterialApp(
        title: 'User Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: initError != null
            ? ErrorScreen(error: initError!)
            : const LoginPage(),
      ),
    );
  }
}


class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initialization Error'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Failed to Initialize App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[800], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Troubleshooting Steps:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _TroubleshootingItem('1. Nếu dùng Android Emulator:'),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 24),
                      child: _TroubleshootingItem('• Mở browser trong emulator kiểm tra internet'),
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 24),
                      child: _TroubleshootingItem('• Restart emulator (đóng và mở lại)'),
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 24),
                      child: _TroubleshootingItem('• Emulator có thể không resolve DNS cho mongodb+srv'),
                    ),
                    const SizedBox(height: 8),
                    const _TroubleshootingItem('2. Kiểm tra MongoDB Atlas Network Access'),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 24),
                      child: _TroubleshootingItem('• Đảm bảo đã whitelist 0.0.0.0/0 (cho phép tất cả)'),
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 24),
                      child: _TroubleshootingItem('• Hoặc thêm IP máy tính host của bạn'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Error Details:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // User needs to restart app manually
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again (Restart App)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TroubleshootingItem extends StatelessWidget {
  final String text;
  
  const _TroubleshootingItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_outline, size: 16, color: Colors.orange),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
