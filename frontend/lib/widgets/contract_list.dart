import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/contract.dart';


class ContractList extends StatelessWidget {
  
  const ContractList({super.key});


  @override
  Widget build(BuildContext context) {

    final provider = context.watch<HunterProvider>();
    
    final List<Contract> contracts = provider.contracts;
    
    final bool isLoading = provider.isLoading;
   
    if (isLoading && contracts.isEmpty) {
     
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (contracts.isEmpty) {
      return const Center(
        child: Text('Nenhum contrato ativo'),
      );
    }
    
   
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
              
                    onPressed: isLoading 
                      ? null 
                      : () {
                 
                        context.read<HunterProvider>().completeContract(contract.id);
                      }
                  )
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
                 
                          onPressed: isLoading
                            ? null
                            : () {
                       
                              context.read<HunterProvider>().surrenderContract(contract.id);
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                          ),
                          child: const Text('Desistir do contrato'),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}