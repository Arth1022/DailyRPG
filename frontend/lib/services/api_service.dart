import 'dart:convert';
import 'package:dailyrpg/models/contract.dart';
import 'package:http/http.dart' as http;
import '../models/hunter_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService{
  
  final _storage = const FlutterSecureStorage();
  final String _tokenKey = 'jwt_token';
  final String _baseUrl= "http://10.0.2.2:5164/api";

  Future<void> _saveToken(String token) async{
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> logout() async {
    await _storage.delete(key:_tokenKey);
  }
  
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken(); 

    if (token == null) {
      throw Exception('Token não encontrado. Faça o login novamente.');
    }

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token', 
    };
  }

  final Map<String, String> _publicHeaders = {
    'Content-Type': 'application/json; charset=UTF-8'
  };
  
  Future<void> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Auth/login'),
        headers: _publicHeaders,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final String token = body['token'];
        await _saveToken(token);
        return;
      }
      
      if (response.statusCode == 401) {
        throw Exception('Credenciais inválidas. Verifique o utilizador e a senha.');
      }
      
      throw Exception('Falha no login (Code: ${response.statusCode})');

    } catch (e) {
      print('EXCEÇÃO [Login]: $e');
      throw Exception('Falha ao conectar ao servidor: $e');
    }
  }

  Future<void> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Auth/register'), 
        headers: _publicHeaders,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 201) {
        return;
      }
      if (response.statusCode == 400) {
        throw Exception(response.body); 
      }
      throw Exception('Falha no registo (Code: ${response.statusCode})');

    } catch (e) {
      print('EXCEÇÃO [Register]: $e');
      throw Exception('$e');
    }
  }
  
  Future<HunterUser> fetchHunterStats() async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/HunterControllers/stats'),
        headers: headers,
      );

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
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/ContractsControllers/undone'),
        headers: headers,
      );
      
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
      final headers = await _getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('$_baseUrl/ContractsControllers/$id/complete/'),
        headers: headers,
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
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/ContractsControllers/abandon/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204){
        return;
      } else {
        print('ERRO NA API [Surrender]: Status Code = ${response.statusCode}');
        print('ERRO NA API [Surrender]: Body = ${response.body}');
        throw Exception('Falha ao abandonar o contrato');
      }
    } catch (e) {
      print('EXCEÇÃO [Surrender]: $e');
      throw Exception('Falha ao conectar ao servidor (Surrender)');
    }
  }

  Future<void> createContract(Map<String, dynamic> contractData) async{
    try{
      final headers = await _getAuthHeaders();
      
      final response =  await http.post(
        Uri.parse('$_baseUrl/ContractsControllers'),
        headers: headers,
        body: jsonEncode(contractData)
      );
      
      if (response.statusCode == 201){
        return;
      }
      else{
        print('ERRO NA API [CREATE]: Status = ${response.statusCode}');
        print('ERRO NA API [CREATE]: Body = ${response.body}');
        throw Exception('Falha ao criar o contrato');
      }
    }catch (e){
      print ('Exceção [CREATE]: $e');
      throw Exception('Erro: $e');
    } 
  }

  Future<void> buyItem(String id) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/ShopControllers/buy/$id'),
        headers: headers,
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