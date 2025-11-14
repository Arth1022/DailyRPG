import 'package:flutter/material.dart';
import '../models/hunter_user.dart';
import '../models/contract.dart';
import '../models/item.dart';
import '../models/inventory_slot.dart';
import '../models/recipe.dart';
import '../models/boss_status.dart';
import '../services/api_service.dart';

class HunterProvider with ChangeNotifier {


  HunterUser? _hunter; 
  List<Contract> _contracts = []; 
  List<Item> _shopItems = []; 
  List<InventorySlot> _inventory = []; 
  List<Recipe> _recipes = []; 
  BossStatus? _bossStatus; 

  bool _isLoading = false;

  String? _errorMessage;


  final ApiService _apiService = ApiService();

 
  HunterUser? get hunter => _hunter;
  List<Contract> get contracts => _contracts;
  List<Item> get shopItems => _shopItems;
  List<InventorySlot> get inventory => _inventory;
  List<Recipe> get recipes => _recipes;
  BossStatus? get bossStatus => _bossStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _hunter != null;

  Future<bool> login(String username, String password) async {

    _setLoading(true);

    try {

      await _apiService.login(username, password);

      await loadInitialData();
  
      _setError(null);
      _setLoading(false);
      return true; 
    } catch (e) {
     
      _setError(e.toString());
      _setLoading(false);
      return false; 
    }
  }

  Future<bool> register(String username, String password) async {

    _setLoading(true);

    try {

      await _apiService.register(username, password);


      _setError(null);
      _setLoading(false);
      return true; 

    } catch (e) {

      _setError(e.toString());
      _setLoading(false);
      return false; 
    }
  }


  Future<void> logout() async {
    await _apiService.logout();
    _hunter = null; 
    _contracts = []; 
    _inventory = [];
    _shopItems = [];
    _recipes = [];
    _bossStatus = null;
    _notify(); 
  }


  Future<void> loadInitialData() async {
    try {
      final results = await Future.wait([
        _apiService.fetchHunterStats(),
        _apiService.fetchContracts(),
        _apiService.fetchShopItems(),
        _apiService.fetchInventory(),
        _apiService.fetchRecipes(),
        _apiService.fetchBossStatus(),
      ]);

    
      _hunter = results[0] as HunterUser;
      _contracts = results[1] as List<Contract>;
      _shopItems = results[2] as List<Item>;
      _inventory = results[3] as List<InventorySlot>;
      _recipes = results[4] as List<Recipe>;
      _bossStatus = results[5] as BossStatus;


      _setError(null);
    } catch (e) {

      print("ERRO AO CARREGAR DADOS INICIAIS: $e");
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _notify(); 
  }


  void _setError(String? error) {
    _errorMessage = error;
    _notify(); 
  }


  void _notify() {
    notifyListeners();
  }
}