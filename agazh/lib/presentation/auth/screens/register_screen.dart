import 'package:agazh/agazsh_route_config.dart';
import 'package:agazh/application/auth/auth_provider.dart';
import 'package:agazh/application/auth/auth_states.dart';
import 'package:agazh/domain/auth/user_model.dart';
import 'package:agazh/presentation/auth/screens/login_screen.dart';
import 'package:agazh/presentation/auth/widgets/role_selection_buttons.dart';
import 'package:agazh/presentation/auth/widgets/sign_up_button.dart';
import 'package:agazh/presentation/job_application/freelancer_home_screen.dart';
import 'package:agazh/presentation/job/client_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  Role _role = Role.client;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
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
                Text('Registration failed. Please try again.'),
              ],
            ),
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Agazsh",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Text(
                'Create an Account',
                style: TextStyle(color: Colors.grey[800], fontSize: 18),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Select Role:'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoleSelectionButton(
                    label: 'Client',
                    value: Role.client,
                    selectedRole: _role,
                    onChanged: (value) {
                      setState(() {
                        _role = value;
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  RoleSelectionButton(
                    label: 'Freelancer',
                    value: Role.freelancer,
                    selectedRole: _role,
                    onChanged: (value) {
                      setState(() {
                        _role = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SignUpButton(
                onTap: () {
                  ref.read(authProvider.notifier).register(
                    usernameController.text,
                    emailController.text,
                    passwordController.text,
                    _role,
                  );
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  ref.read(authProvider.notifier).initialize();
                  context.go(PathName.logIn);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    SizedBox(width: 4),
                    Text(
                      "Log In",
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
      ),
    );
  }
}
