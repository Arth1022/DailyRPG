import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';


class AddContractScreen extends StatefulWidget{
  const AddContractScreen({super.key});

  @override
  State<AddContractScreen> createState() => _AddContractScreenState();
}

class _AddContractScreenState extends State<AddContractScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController= TextEditingController();
  final _xpController = TextEditingController();
  final _coinController = TextEditingController();

  @override
  void dispose(){
    _titleController.dispose();
    _descController.dispose();
    _xpController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()){
      return;
    }

    final provider = context.read<HunterProvider>();

    final contractData = {
      'id' : 0,
      'title': _titleController.text,
      'descricao': _descController.text.isEmpty 
          ? 'Sem detalhes sobre a missão' 
          : _descController.text,
      'xpReward': int.tryParse(_xpController.text) ?? 0,
      'coinReward': int.tryParse(_coinController.text) ?? 0,
      'isCompleted': false,
      'startDate': DateTime.now().toIso8601String(),
      'difficult': 'Normal',
    };
    
    final bool success = await provider.createContract(contractData);

    if (success) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context){
    final bool isLoading = context.watch<HunterProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Contrato'),
      ),
      body:
        isLoading 
            ? const Center(child: CircularProgressIndicator(),)
            : Form(
                key: _formKey,
                child:
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(
                        controller: _titleController,
                        enabled: !isLoading,
                        decoration: const InputDecoration(labelText: 'Missão'),
                        validator: (value){
                          if (value == null || value.isEmpty){
                            return 'Seu contrato não tem nenhum objetivo!';
                          }
                          return null; 
                        },
                      ),
                      const SizedBox(height: 16,),
                      TextFormField(
                        controller: _descController,
                        enabled: !isLoading,
                        decoration: InputDecoration(labelText: 'Detalhes do contrato'),
                        validator: (value){
                          return null;
                        }
                      ),
                      const SizedBox(height: 16,),
                      TextFormField(
                        controller: _xpController,
                        enabled: !isLoading,
                        decoration: const InputDecoration(labelText: 'XP'),
                        keyboardType: TextInputType.number,
                        validator: (value){
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
                      const SizedBox(height: 32,),
                      TextFormField(
                        controller: _coinController,
                        enabled: !isLoading,
                        decoration: InputDecoration(labelText: 'Recompensa'),
                        keyboardType: TextInputType.number,
                        validator: (value){
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
                      const SizedBox(height: 32,),

                      ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        child: const Text('Assinar Contrato'),
                      )
                    ],
                  ),
                )
    );
  }
}