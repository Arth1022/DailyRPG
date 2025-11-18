import 'package:flutter/material.dart';
import 'package:dailyrpg/screens/register_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Importar fontes
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Importar ícones
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

  // --- Estilos de Tema ---
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkCardColor = Color(0xff2a2a2a);
  static const pixelPrimaryColor = Color.fromARGB(255, 77, 167, 209);

  TextStyle get _inputTextStyle =>
      GoogleFonts.pixelifySans(fontSize: 14, color: Colors.white);

  TextStyle get _pixelTitleStyle =>
      GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white);
  // ------------------------

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
          MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }

  // Helper para estilizar os Inputs
  InputDecoration _pixelInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: _inputTextStyle.copyWith(color: Colors.white70),
      prefixIcon: Icon(icon, color: pixelPrimaryColor, size: 20),
      fillColor: darkCardColor,
      filled: true,

      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24, width: 1.5),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: pixelPrimaryColor, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 3),
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.watch<HunterProvider>().isLoading;

    return Scaffold(
      backgroundColor: darkBackground, // Fundo escuro
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(44.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 500, // Reduzido de 500 para 250
                    height: 500, // Reduzido de 500 para 250
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          enabled: !isLoading,
                          style: _inputTextStyle, // Estilo do texto
                          decoration: _pixelInputDecoration(
                            label: 'Usuário',
                            icon: FontAwesomeIcons.user,
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
                          style: _inputTextStyle, // Estilo do texto
                          decoration: _pixelInputDecoration(
                            label: 'Senha',
                            icon: FontAwesomeIcons.key,
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
                            backgroundColor: pixelPrimaryColor,
                            foregroundColor:
                                darkCardColor, // Cor do texto/ícone
                            shape: const BeveledRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: Colors.white54, width: 2),
                            ),
                          ),
                          onPressed: isLoading ? null : _login,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: darkCardColor,
                                )
                              : Text(
                                  'ENTRAR',
                                  style: _pixelTitleStyle.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 5.0),
                        TextButton(
                          onPressed: isLoading ? null : _navigateToRegister,
                          child: Text(
                            'Não tem conta? Registar',
                            style: _inputTextStyle.copyWith(
                              color: pixelPrimaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
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
                style: _inputTextStyle.copyWith(
                  // Estilo do texto
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: pixelPrimaryColor,
                ), // Estilo do loading
              ),
            ),
        ],
      ),
    );
  }
}
