import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const darkBackground = Color(0xFF1A1A1A);
  static const darkCardColor = Color(0xff2a2a2a);
  static const pixelPrimaryColor = Color.fromARGB(255, 77, 167, 209);

  TextStyle get _inputTextStyle =>
      GoogleFonts.pixelifySans(fontSize: 14, color: Colors.white);

  TextStyle get _pixelTitleStyle =>
      GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white);
  // ---------------------------------------------

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<HunterProvider>();

      final bool success = await provider.register(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registo bem-sucedido! Faça o login.',
              style: _inputTextStyle.copyWith(fontSize: 10),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro no Registo: ${provider.errorMessage}',
              style: _inputTextStyle.copyWith(fontSize: 10),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Text('REGISTAR', style: _pixelTitleStyle.copyWith(fontSize: 12)),
        backgroundColor: darkCardColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
        
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _usernameController,
                    enabled: !isLoading,
                    style: _inputTextStyle,
                    decoration: _pixelInputDecoration(
                      label: 'Usuário',
                      icon: FontAwesomeIcons.user,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um utilizador';
                      }
                      if (value.length < 3) {
                        return 'O utilizador deve ter pelo menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !isLoading,
                    style: _inputTextStyle,
                    decoration: _pixelInputDecoration(
                      label: 'Senha',
                      icon: FontAwesomeIcons.key,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    enabled: !isLoading,
                    style: _inputTextStyle,
                    decoration: _pixelInputDecoration(
                      label: 'Confirmar Senha',
                      icon: FontAwesomeIcons.lock,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme a sua senha';
                      }
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: pixelPrimaryColor,
                      foregroundColor: darkCardColor,
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Colors.white54, width: 2),
                      ),
                    ),
                    onPressed: isLoading ? null : _register,
                    child: isLoading
                        ? const CircularProgressIndicator(color: darkCardColor)
                        : Text(
                            'REGISTAR',
                            style: _pixelTitleStyle.copyWith(fontSize: 12),
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: pixelPrimaryColor),
              ),
            ),
        ],
      ),
    );
  }
}
