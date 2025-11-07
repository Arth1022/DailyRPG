// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dailyrpg/models/contract.dart';
import 'package:http/http.dart' as http;
import '../models/hunter_user.dart';

class ApiService{
  final String _baseUrl= "http://10.0.2.2:5164/api";
  final Map<String, String> _headers ={
    'Content-Type': 'application/json; charset=UTF-8'
  } ;

  Future<HunterUser> fetchHunterStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/HunterControllers/stats'));

      if (response.statusCode == 200) {
        return HunterUser.fromJson(jsonDecode(response.body));
      } else {
        print('ERRO API [Hunter]: Status Code = ${response.statusCode}');
        print('ERRO API [Hunter]: Body = ${response.body}');
        throw Exception('Falha ao carregar os stats do caçador (StatusCode: ${response.statusCode})');
      }
    } catch (e) {
      print('EXCEÇÃO [Hunter]: $e');
      throw Exception('Falha ao conectar ao servidor (Hunter): $e');
    }
  }

  Future<List<Contract>> fetchContracts() async{
    try {
      final response = await http.get(Uri.parse('$_baseUrl/ContractsControllers/undone'));
      
      if (response.statusCode == 200){
        print('JSON RESPOSTA [Contracts]: ${response.body}');
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((jsonItem) => Contract.fromJson(jsonItem)).toList();
      } 
      else {
        print('ERRO API [Contracts]: Status Code = ${response.statusCode}');
        print('ERRO API [Contracts]: Body = ${response.body}');
        throw Exception('Falha ao carregar contrato (StatusCode: ${response.statusCode})');
      }
    } catch (e) {
      print('EXCEÇÃO [Contracts]: $e');
      throw Exception('Falha ao conectar ao servidor (Contracts): $e');
    }
  }
  Future<void> completeContract(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/ContractsControllers/$id/complete/'),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        print('ERRO API [Complete]: Status Code = ${response.statusCode}');
        print('ERRO API [Complete]: Body = ${response.body}');
        throw Exception('Falha ao completar o contrato');
      }
    } catch (e) {
      print('EXCEÇÃO [Complete]: $e');
      throw Exception('Falha ao conectar ao servidor (Complete)');
    }
  }
  Future<void> surrenderContract(String id) async {
    final response = await http.post(Uri.parse('$_baseUrl/ContractsControllers/abandon/$id'));

    if (response.statusCode == 200 || response.statusCode == 204){
      return;
    } else {
      print('ERRO NA API [CONTROLLER]: Status Code = ${response.statusCode}');
      print('ERRO NA API [CONTROLLER]: Body = ${response.body}');
    }
  }

  Future<void> createContract(Map<String, dynamic> contractData) async{
    try{
      final response =  await http.post(Uri.parse('$_baseUrl/ContractsControllers'),headers: _headers, body: jsonEncode(contractData));
      if (response.statusCode == 200 || response.statusCode == 202){
      return;
      }
    else{
      print('ERRO NA API [CREATE]: Status = ${response.statusCode}');
      print('ERRO NA API [CREATE]: Body = ${response.body}');
    }
    }catch (e){
    print ('Exceção [CREATE]: $e');
    } 
  }
  Future<void> buyItem(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ShopControllers/buy/$id'),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        print('ERRO NA API [SHOP]: StatusCode = ${response.statusCode}');
        print('ERRO NA API [SHOP]: Body = ${response.body}');
        throw Exception('Falha ao comprar (Code: ${response.statusCode})');
      }
    } catch (e) {
      print('EXEÇÃO [Shop]: $e');
      throw Exception('Erro: $e');
    }
  }
}