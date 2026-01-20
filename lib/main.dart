import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rentalify/core/themes/app_theme.dart';
import 'package:rentalify/features/main/pages/main_page.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/pages/login_page.dart';
import 'features/home/cubit/home_cubit.dart';
import 'features/borrowing/cubit/borrowing_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // GANTI dengan Supabase URL dan Anon Key lu
  await SupabaseService().initialize(
    supabaseUrl: 'https://yhdiryaptdcgbqvehqrh.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InloZGlyeWFwdGRjZ2JxdmVocXJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyNDYzNTYsImV4cCI6MjA4MzgyMjM1Nn0.HXDXVPANX8V1aRCwQTTwh9dwjd913jCepcjuvJ61wj8',
  );

  // Initialize date formatting untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(SupabaseService())..checkAuthStatus(),
        ),
        BlocProvider(
          create: (context) => HomeCubit(SupabaseService()),
        ),
        BlocProvider(
          create: (context) => BorrowingCubit(SupabaseService()),
        ),
      ],
      child: MaterialApp(
        title: 'Alat Otomotif App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Listen to auth state changes and navigate accordingly
        if (state.status == AuthStatus.authenticated) {
          // Navigate to MainPage when authenticated
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
            (route) => false,
          );
        } else if (state.status == AuthStatus.unauthenticated) {
          // Navigate to LoginPage when unauthenticated
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // Initial loading screen
          if (state.status == AuthStatus.loading ||
              state.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Default to LoginPage
          if (state.status == AuthStatus.authenticated) {
            return const MainPage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}