import 'package:agazh/agazsh_route_config.dart';
import 'package:agazh/application/auth/auth_provider.dart';
import 'package:agazh/application/auth/auth_states.dart';
import 'package:agazh/domain/auth/user_model.dart';
import 'package:agazh/presentation/auth/screens/register_screen.dart';
import 'package:agazh/presentation/job_application/freelancer_home_screen.dart';
import 'package:agazh/presentation/job/client_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agazh/presentation/auth/widgets/log_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, state) {
      if (state is AuthSuccessState) {
        if (state.user.role == Role.freelancer) {
          context.go(PathName.freelancer);
        } else {
          context.go(PathName.client);
        }
      } else if (state is AuthErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Login failed. Please try again.'),
              ],
            ),
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Builder(
          builder: (context) {
            if (authState is AuthLoadingState) {
              return const CircularProgressIndicator();
            }
            return SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        "Agazsh",
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'Welcome! Please login.',
                        style: TextStyle(
                            color: Colors.grey[800], fontSize: 18),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'username',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    },
                                    icon: Icon(obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                                labelText: 'Password',
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: obscureText,
                            ),
                            const SizedBox(height: 20),
                            LogInButton(
                              ontap: () {
                                ref.read(authProvider.notifier).login(
                                  usernameController.text,
                                  passwordController.text,
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                context.go(PathName.register);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Not a member?"),
                                  SizedBox(width: 4),
                                  Text(
                                    " Register",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
          },
        ),
      ),
    );
  }
}
