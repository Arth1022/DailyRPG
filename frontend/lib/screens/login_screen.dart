import 'package:flutter/material.dart';
import 'package:dailyrpg/screens/register_screen.dart';

import 'package:provider/provider.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/screens/home_screen.dart'; 


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      
      final provider = context.read<HunterProvider>();

      final bool success = await provider.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no Login: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder:(context) => const RegisterScreen(),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.watch<HunterProvider>().isLoading;

    return Scaffold(
      body: Stack(
        children: [
          Center( 
            child: SingleChildScrollView( 
              padding: const EdgeInsets.all(44.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 500,
                    height: 500, 
                    decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage('assets/images/logo.png') ,
                            fit: BoxFit.cover
                        )
                    ),
                  ) ,   
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Usuário',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o seu utilizador';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira a sua senha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: isLoading ? null : _login,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Entrar'),
                        ),
                        const SizedBox(height: 5.0),
                        TextButton(
                          onPressed: isLoading ? null : _navigateToRegister,
                          child: const Text('Não tem conta? Registar'),
                        ),
                        SizedBox(height: 60,)
                      ],
                      
                    ),
                    
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0), 
              child: Text(
                'Ao continuar, você concorda com nossos Termos de Serviço.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}