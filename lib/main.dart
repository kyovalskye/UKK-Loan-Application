import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rentalify/core/themes/app_theme.dart';
import 'package:rentalify/app/pages/main_shell_page.dart';
import 'package:rentalify/features/modules/approval/cubit/approval_cubit.dart';
import 'package:rentalify/features/modules/borrowing/cubit/borrowing_cubit.dart';
import 'package:rentalify/features/modules/borrowing/cubit/borrowing_list_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/crud_user_cubit.dart'; // TAMBAHKAN INI
import 'core/services/supabase_service.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/pages/login_page.dart';
import 'features/home/cubit/home_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await SupabaseService().initialize(
    supabaseUrl: dotenv.env['SUPABASE_URL']!,
    supabaseAnonKey: dotenv.env['SUPABASE_KEY']!,
  );

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
        BlocProvider(
          create: (context) => BorrowingListCubit(SupabaseService()),
        ),
        BlocProvider(
          create: (context) => ApprovalCubit(SupabaseService()),
        ),
        BlocProvider(  // TAMBAHKAN INI
          create: (context) => CrudUserCubit(),
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
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainShellPage()),
            (route) => false,
          );
        } else if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.loading ||
              state.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state.status == AuthStatus.authenticated) {
            return const MainShellPage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}