import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../models/contract.dart';

class ContractList extends StatefulWidget {
  final VoidCallback onDataChanged;

  const ContractList({super.key, required this.onDataChanged});

  @override
  State<ContractList> createState() => ContractListState();
}

class ContractListState extends State<ContractList> {
  final ApiService _apiService = ApiService();
  late Future<List<Contract>> _contractsFuture;

  @override
  void initState() {
    super.initState();
    _contractsFuture = _apiService.fetchContracts();
  }

  void refreshContracts(){
    setState(() {
    _contractsFuture = _apiService.fetchContracts();
    });
  }

  void _completeContract(String id) async {
    try {
      await _apiService.completeContract(id);
      widget.onDataChanged();
      setState(() {
        _contractsFuture = _apiService.fetchContracts();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Deu ruim chefe')));
    }
  }

  void _abandonContract(String id) async {
    try {
      await _apiService.surrenderContract(id);
      widget.onDataChanged();
      setState(() {
        _contractsFuture = _apiService.fetchContracts();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Deu ruim chefe")));
    }
    //Widget _iconFilter(String status){
    //  if (Contract. == )
    //}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contract>>(
        future: _contractsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar contratos: ${snapshot.error}',
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum contrato ativo'),
            );
          }
          final contracts = snapshot.data!;

          return Expanded(
            child: ListView.builder(
                itemCount: contracts.length,
                itemBuilder: (context, index) {
                  final contract = contracts[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xff222222),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          const Icon(
                            Icons.sports_gymnastics
                          ),
                          SizedBox(width: 16,),

                          Expanded(
                            child: Text(
                              contract.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                              icon: const Icon(
                                Icons.check_box_outlined,
                                color: Colors.green,
                              ),
                              onPressed: () => _completeContract(contract.id))
                        ],
                      ),
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(contract.description),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Inicio : ${contract.startDate?.toString() ?? 'N/A'}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Recompensa: ${contract.xpReward} XP, ${contract.coinReward} G"),
                                const SizedBox(
                                  height: 15,
                                ),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _abandonContract(contract.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[800],
                                    ),
                                    child: const Text('Desistir do contrato'),
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                  );
                }),
          );
        });
  }
}