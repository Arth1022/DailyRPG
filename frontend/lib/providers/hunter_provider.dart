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
  Future<void> completeContract(int id) async {
    _setLoading(true);
    try {
      
      final updatedHunter = await _apiService.completeContract(id);
      
      _hunter = updatedHunter;


      _contracts = await _apiService.fetchContracts();
      _bossStatus = await _apiService.fetchBossStatus();
      _inventory = await _apiService.fetchInventory();
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {

      _setLoading(false);
    }
  }

  Future<bool> createContract(Map<String, dynamic> contractData) async {
    _setLoading(true);
    
    try {
      await _apiService.createContract(contractData);
      
      _contracts = await _apiService.fetchContracts();

      _setError(null);
      _setLoading(false);
      return true; 

    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false; 
    }   
  }

  Future<void> surrenderContract(int id) async {
    _setLoading(true);
    try {
      await _apiService.surrenderContract(id);
      
      
      _contracts = await _apiService.fetchContracts();
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      rethrow; 
    } finally {
      _setLoading(false);
    }
  }

  Future<void> buyItem(int id) async {
    _setLoading(true);
    try {
      await _apiService.buyItem(id);
      

      _hunter = await _apiService.fetchHunterStats();
  
      _inventory = await _apiService.fetchInventory();
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      
      rethrow; 
    } finally {
      _setLoading(false);
    }
  }

  Future<void> useItem(int slotId) async {
    _setLoading(true);
    try {

      final updatedHunter = await _apiService.useItem(slotId);
      _hunter = updatedHunter;

      _inventory = await _apiService.fetchInventory();
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      rethrow; 
    } finally {
      _setLoading(false);
    }
  }

  Future<void> craftItem(int recipeId) async {
    _setLoading(true);
    try {
      await _apiService.craftItem(recipeId);
      
      _inventory = await _apiService.fetchInventory();
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      rethrow; 
    } finally {
      _setLoading(false);
    }
  }

  Future<void> spendAttributePoint(String skillName) async {
    _setLoading(true);
    try {

      final updatedHunter = await _apiService.spendAttributePoint(skillName);
      
      _hunter = updatedHunter;
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      rethrow; 

    } finally {
      _setLoading(false);
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