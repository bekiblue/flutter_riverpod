import 'package:agazh/agazsh_route_config.dart';
import 'package:agazh/application/auth/auth_provider.dart';
import 'package:agazh/application/auth/auth_states.dart';
import 'package:agazh/application/job/job_provider.dart';  // Assuming JobBloc is still using BLoC
import 'package:agazh/application/job_application/job_application_provider.dart';  // Assuming JobApplicationBloc is still using BLoC
import 'package:agazh/domain/auth/user_model.dart';
import 'package:agazh/presentation/auth/screens/login_screen.dart';
import 'package:agazh/presentation/job_application/freelancer_home_screen.dart';
import 'package:agazh/presentation/job/client_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AgazshRoute().router,
      title: 'Agazsh',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState is AuthSuccessState) {
        if (authState.user.role == Role.freelancer) {
          context.go(PathName.freelancer);
        } else {
          context.go(PathName.client);
        }
      } else if (authState is AuthErrorState || authState is AuthIitialState) {
        context.go(PathName.logIn);
      }
    });

    return const Scaffold(
      body: Center(
        child: Text(
          "Agazh",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
