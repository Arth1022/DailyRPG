import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';

class AddContractScreen extends StatefulWidget {
  const AddContractScreen({super.key});

  @override
  State<AddContractScreen> createState() => _AddContractScreenState();
}

class _AddContractScreenState extends State<AddContractScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _xpController = TextEditingController();
  final _coinController = TextEditingController();

  // --- Variável de Estado para a Dificuldade ---
  String _selectedDifficulty = 'Normal';

  // --- Opções de Dificuldade ---
  final List<String> _difficulties = ['Fácil', 'Normal', 'Difícil', 'Épico'];

  // --- Estilos de Tema ---
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkCardColor = Color(0xff2a2a2a);
  static const pixelPrimaryColor = Color.fromARGB(255, 77, 167, 209);
  static const xpColor = Color.fromARGB(255, 85, 166, 82);
  static const goldColor = Colors.amber;
  // ------------------------

  TextStyle get _inputTextStyle =>
      GoogleFonts.pixelifySans(fontSize: 14, color: Colors.white);

  TextStyle get _pixelTitleStyle =>
      GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white);

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _xpController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<HunterProvider>();

    final contractData = {
      'id': 0,
      'title': _titleController.text,
      'descricao': _descController.text.isEmpty
          ? 'Sem detalhes sobre a missão'
          : _descController.text,
      'xpReward': int.tryParse(_xpController.text) ?? 0,
      'coinReward': int.tryParse(_coinController.text) ?? 0,
      'isCompleted': false,
      'startDate': DateTime.now().toIso8601String(),
      // --- Usando a Dificuldade Selecionada ---
      'difficult': _selectedDifficulty,
    };

    final bool success = await provider.createContract(contractData);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Contrato assinado com sucesso!',
            style: _inputTextStyle.copyWith(fontSize: 10),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao criar: ${provider.errorMessage}',
            style: _inputTextStyle.copyWith(fontSize: 10),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _pixelInputDecoration({
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: _inputTextStyle.copyWith(color: Colors.white70),
      prefixIcon: Icon(icon, color: iconColor),
      fillColor: darkCardColor,
      filled: true,

      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24, width: 1.5),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: OutlineInputBorder(
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
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 12.0,
      ),
    );
  }

  // --- Função auxiliar para obter a cor da dificuldade ---
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Fácil':
        return Colors.green;
      case 'Normal':
        return Colors.yellow;
      case 'Difícil':
        return Colors.orange;
      case 'Épico':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.watch<HunterProvider>().isLoading;

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkCardColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('NOVO CONTRATO', style: _pixelTitleStyle),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: pixelPrimaryColor),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // CAMPO: MISSÃO (TÍTULO)
                  TextFormField(
                    controller: _titleController,
                    enabled: !isLoading,
                    style: _inputTextStyle,
                    decoration: _pixelInputDecoration(
                      label: 'Missão',
                      icon: FontAwesomeIcons.scroll,
                      iconColor: pixelPrimaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seu contrato não tem nenhum objetivo!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // CAMPO: DETALHES (DESCRIÇÃO)
                  TextFormField(
                    controller: _descController,
                    enabled: !isLoading,
                    style: _inputTextStyle,
                    maxLines: 3,
                    decoration: _pixelInputDecoration(
                      label: 'Detalhes do Contrato',
                      icon: FontAwesomeIcons.bookOpen,
                      iconColor: Colors.grey,
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- CAMPO: DIFICULDADE (COMBOBOX) ---
                  DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    isExpanded: true,
                    dropdownColor: darkCardColor,
                    style: _inputTextStyle,
                    decoration:
                        _pixelInputDecoration(
                          label: 'Dificuldade',
                          icon: FontAwesomeIcons.mapMarkerAlt,
                          iconColor: _getDifficultyColor(
                            _selectedDifficulty,
                          ), // Cor dinâmica
                        ).copyWith(
                          // Customiza o label para o Dropdown
                          labelText: 'Dificuldade',
                        ),
                    items: _difficulties.map((String difficulty) {
                      return DropdownMenuItem<String>(
                        value: difficulty,
                        child: Text(
                          difficulty,
                          style: _inputTextStyle.copyWith(
                            color: _getDifficultyColor(difficulty),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDifficulty = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione uma dificuldade.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // CAMPO: RECOMPENSA XP
                  TextFormField(
                    controller: _xpController,
                    enabled: !isLoading,
                    style: _inputTextStyle,
                    decoration: _pixelInputDecoration(
                      label: 'Recompensa de XP',
                      icon: FontAwesomeIcons.diamond,
                      iconColor: xpColor,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final xp = int.tryParse(value ?? '');
                      if (xp == null) {
                        return 'XP deve ser um número';
                      }
                      if (xp <= 0) {
                        return 'Nenhum XP atribuído';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // CAMPO: RECOMPENSA COINS
                  TextFormField(
                    controller: _coinController,
                    enabled: !isLoading,
                    style: _inputTextStyle,
                    decoration: _pixelInputDecoration(
                      label: 'Recompensa em Ouro (Gold)',
                      icon: FontAwesomeIcons.coins,
                      iconColor: goldColor,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final coins = int.tryParse(value ?? '');
                      if (coins == null) {
                        return 'Recompensa deve ser um número';
                      }
                      if (coins < 0) {
                        return 'Não pode ser negativo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // BOTÃO: ASSINAR CONTRATO
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pixelPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Colors.white54, width: 2),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'ASSINAR CONTRATO',
                      style: _pixelTitleStyle.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
