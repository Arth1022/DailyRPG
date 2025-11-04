import 'dart:convert'; //Tradutor do json
import 'package:http/http.dart' as http; //API
import '../models/hunter_user.dart';

class ApiService{
  final String _baseUrl= "http://10.0.2.2:5164/api"; //String de conexao

  Future<HunterUser> fetchHunterStats() async {

    final Uri url = Uri.parse('$_baseUrl/HunterControllers/stats');
    try{
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return HunterUser.fromJson(jsonDecode(response.body));
      } else{
        throw Exception('Falha ao carregar os stats (Cogido: ${response.statusCode}');
      }
    } catch (e){
      throw Exception('Falha de conexão: $e');
    }
  }
}