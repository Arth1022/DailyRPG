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

  // --- Variável de Estado para a Dificuldade ---
  String _selectedDifficulty = 'Normal';

  // --- Opções de Dificuldade (Visual) ---
  final List<String> _difficulties = ['Fácil', 'Normal', 'Difícil', 'Épico'];

  // --- PALETA "DUNGEON" ---
  static const Color _bgDark = Color(0xFF050505);
  static const Color _stoneDark = Color(0xFF1C1C1C);
  static const Color _ironGrey = Color(0xFF455A64);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _inputFill = Color(0xFF121212); // Fundo dos inputs

  TextStyle get _pixelTitle =>
      GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white);
  TextStyle get _pixelLabel =>
      GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white54);
  TextStyle get _pixelInput =>
      GoogleFonts.pixelifySans(fontSize: 14, color: Colors.white);

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Converte o nome visual para o nome que a API espera (inglês)
  String _getBackendDifficulty(String displayValue) {
    switch (displayValue) {
      case 'Fácil':
        return 'easy';
      case 'Normal':
        return 'medium';
      case 'Difícil':
        return 'hard';
      case 'Épico':
        return 'legendary';
      default:
        return 'medium';
    }
  }

  // Preview de Recompensa
  String _getRewardPreview(String displayValue) {
    switch (displayValue) {
      case 'Fácil':
        return '50 XP / 15 Gold';
      case 'Normal':
        return '100 XP / 40 Gold';
      case 'Difícil':
        return '300 XP / 100 Gold';
      case 'Épico':
        return '800 XP / 300 Gold';
      default:
        return '';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<HunterProvider>();

    final contractData = {
      'id': 0,
      'title': _titleController.text,
      'descricao': _descController.text.isEmpty
          ? 'Sem detalhes sobre a missão'
          : _descController.text,
      'isCompleted': false,
      'startDate': DateTime.now().toIso8601String(),
      'difficulty': _getBackendDifficulty(_selectedDifficulty),
    };

    final bool success = await provider.createContract(contractData);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CONTRATO OFICIALIZADO!',
            style: _pixelTitle.copyWith(fontSize: 10),
          ),
          backgroundColor: Colors.green[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ERRO NA GUILDA: ${provider.errorMessage}',
            style: _pixelInput,
          ),
          backgroundColor: Colors.red[900],
        ),
      );
    }
  }

  // Decoração Customizada para Inputs (Estilo Pedra/Metal)
  InputDecoration _dungeonInputDecoration({
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return InputDecoration(
      labelText: label.toUpperCase(),
      labelStyle: _pixelLabel,
      prefixIcon: Icon(icon, color: iconColor, size: 18),
      fillColor: _inputFill,
      filled: true,
      border: InputBorder
          .none, // Remove borda padrão para usar Container decoration se quisesse, mas aqui usaremos border customizada

      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white12, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: _gold, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 12.0,
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Fácil':
        return Colors.greenAccent;
      case 'Normal':
        return Colors.blueAccent;
      case 'Difícil':
        return Colors.orangeAccent;
      case 'Épico':
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.watch<HunterProvider>().isLoading;

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _stoneDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FontAwesomeIcons.scroll,
              size: 16,
              color: Colors.white54,
            ),
            const SizedBox(width: 10),
            Text('NOVO CONTRATO', style: _pixelTitle),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: _ironGrey, height: 2),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CABEÇALHO DA FICHA
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _stoneDark,
                        border: Border.all(color: _ironGrey, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 10),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            FontAwesomeIcons.penNib,
                            color: _gold,
                            size: 30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "FORMULÁRIO DA GUILDA",
                            style: _pixelLabel.copyWith(color: Colors.white38),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "REGISTRAR MISSÃO",
                            style: _pixelTitle.copyWith(color: _gold),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TÍTULO
                          Text(
                            "OBJETIVO PRINCIPAL",
                            style: _pixelLabel.copyWith(color: _gold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            enabled: !isLoading,
                            style: _pixelInput,
                            decoration: _dungeonInputDecoration(
                              label: 'Título da Missão',
                              icon: FontAwesomeIcons.dungeon,
                              iconColor: Colors.white70,
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'A missão precisa de um nome!'
                                : null,
                          ),

                          const SizedBox(height: 20),

                          // DESCRIÇÃO
                          Text(
                            "DETALHES DA EXECUÇÃO",
                            style: _pixelLabel.copyWith(color: _gold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descController,
                            enabled: !isLoading,
                            style: _pixelInput,
                            maxLines: 4,
                            decoration: _dungeonInputDecoration(
                              label: 'Descrição',
                              icon: FontAwesomeIcons.alignLeft,
                              iconColor: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // DIFICULDADE
                          Text(
                            "NÍVEL DE AMEAÇA",
                            style: _pixelLabel.copyWith(color: _gold),
                          ),
                          const SizedBox(height: 8),
                          Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: _stoneDark, // Cor do menu dropdown
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedDifficulty,
                              isExpanded: true,
                              style: _pixelInput,
                              decoration: _dungeonInputDecoration(
                                label: 'Dificuldade',
                                icon: FontAwesomeIcons.skull,
                                iconColor: _getDifficultyColor(
                                  _selectedDifficulty,
                                ),
                              ),
                              items: _difficulties.map((String difficulty) {
                                return DropdownMenuItem<String>(
                                  value: difficulty,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: _getDifficultyColor(difficulty),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        difficulty.toUpperCase(),
                                        style: _pixelInput,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedDifficulty = val!),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // PREVIEW DE RECOMPENSA (ESTILO LOOT)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: _ironGrey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.sackDollar,
                                      color: Colors.white38,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Text("PAGAMENTO:", style: _pixelLabel),
                                  ],
                                ),
                                Text(
                                  _getRewardPreview(_selectedDifficulty),
                                  style: _pixelInput.copyWith(
                                    color: _gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // BOTÃO DE ASSINAR
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF2b0505,
                                ), // Vermelho escuro
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: const BeveledRectangleBorder(
                                  side: BorderSide(color: _gold, width: 1),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.fileSignature,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'OFICIALIZAR CONTRATO',
                                    style: _pixelTitle.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
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
