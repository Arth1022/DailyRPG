import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddContractScreen extends StatefulWidget{
  
  const AddContractScreen({super.key});

  @override
  State<AddContractScreen> createState() => _AddContractScreenState();
}

class _AddContractScreenState extends State<AddContractScreen> {

  final _formKey = GlobalKey<FormState>();

  final _apiService = ApiService();

  final _titleController = TextEditingController();
  final _descController= TextEditingController();
  final _xpController = TextEditingController();
  final _coinController = TextEditingController();

  bool _isLoading = false;

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
    setState(() {
      _isLoading =true;
    });

    //Json pra mandar na API
    final contractData = {
      'id' : 0,
      'title': _titleController.text,
      'descricao': _descController.text,
      'xpReward': int.tryParse(_xpController.text) ?? 0,
      'coinReward': int.tryParse(_coinController.text) ?? 0,
      'isCompleted': false,
      'startDate': DateTime.now().toIso8601String(),
      'difficult': 'Normal',
    };
    try{
      await _apiService.createContract(contractData);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e){
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deu ruim chefe')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _isLoading 
            ?const Center(child: CircularProgressIndicator(),)
            : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Missão'),
                    validator: (value){
                      if (value == null || value.isEmpty){
                        return 'Seu contrato não tem nenhum objetivo!';
                      }
                      return null; //Passou na validacao
                    },
                  ),
                  const SizedBox(height: 16,),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(labelText: 'Detalhes do contrato'),
                    validator: (value){
                      if (value == null || value.isEmpty){
                        value = 'Sem datalhes sobre a missão';
                      }
                    }
                  ),
                  const SizedBox(height: 16,),
                  TextFormField(
                    controller: _xpController,
                    decoration: const InputDecoration(labelText: 'XP'),
                    validator: (value){
                      if (value == null || value.isEmpty || value == 0){
                        return 'Nenhum XP atribuido';
                      }
                      if (int.tryParse(value) == null){
                        return 'XP deve ser um número';
                      }
                      return null;
              
                    },
                  ),
                  const SizedBox(height: 32,),
                  TextFormField(
                    controller: _coinController,
                    decoration: InputDecoration(labelText: 'Recompensa'),
                    validator: (value){
                      if (value == 0 || value == null){
                        return 'Contrato sera gratuito mesmo?';
                      }
                      if (int.tryParse(value) == null){
                        return 'Coin deve ser um número';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32,),

                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Assinar Contrato'),
                  )
                ],
              ),
            )
    );
  }
}