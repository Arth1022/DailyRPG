import 'package:flutter/material.dart';
import '../models/hunter_user.dart';
import '../models/contract.dart';
import '../models/item.dart';
import '../models/inventory_slot.dart';
import '../models/recipe.dart';
import '../models/boss_status.dart';
import '../models/battle_state.dart';
import '../services/api_service.dart';

class HunterProvider with ChangeNotifier {
  HunterUser? _hunter;
  List<Contract> _contracts = [];
  List<Item> _shopItems = [];
  List<InventorySlot> _inventory = [];
  List<Recipe> _recipes = [];
  BossStatus? _bossStatus;
  BattleState? _battleState;
  BattleState? get battleState => _battleState;

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

  Future<bool> startPvPBattle() async {
    _setLoading(true);
    try {
      _battleState = await _apiService.startBattle();
      _setError(null);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> battleAction(
    String actionType, {
    String? moveId,
    int? itemId,
  }) async {
    if (_battleState == null) return;

    try {
      final body = {
        'actionType': actionType,
        if (moveId != null) 'moveId': moveId,
        if (itemId != null) 'itemId': itemId,
      };

      final newState = await _apiService.performBattleAction(
        _battleState!.sessionId,
        body,
      );

      _battleState = newState;

      if (actionType == 'item' && itemId != null) {
        final slotIndex = _inventory.indexWhere((s) => s.item.id == itemId);
        if (slotIndex != -1) {
          _inventory[slotIndex].quantity -= 1;
          if (_inventory[slotIndex].quantity <= 0) {
            _inventory.removeAt(slotIndex);
          }
        }
      }

      if (newState.finished) {
        _hunter = await _apiService.fetchHunterStats();
      }

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _notify();
    }
  }

  void clearBattle() {
    _battleState = null;
    _notify();
  }

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

  // --- ESTA É A FUNÇÃO CORRIGIDA ---
  Future<void> completeContract(int id) async {
    _setLoading(true);
    try {
      final updatedHunter = await _apiService.completeContract(id);

      _hunter = updatedHunter;

      // 1. Apenas remove da lista local (sem re-buscar da API)
      _contracts.removeWhere((contract) => contract.id == id);

      // 2. Atualiza o chefe (necessário)
      _bossStatus = await _apiService.fetchBossStatus();

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      // 3. Notifica a tela
      _setLoading(false);
    }
  }
  // --- FIM DA CORREÇÃO ---

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

  Future<String> surrenderContract(int id) async {
    _setLoading(true);
    try {
      final result = await _apiService.surrenderContract(id);

      _contracts.removeWhere((contract) => contract.id == id);

      if (_hunter != null && result.containsKey('remainingHp')) {
        _hunter = HunterUser(
          id: _hunter!.id,
          userId: _hunter!.userId,
          hunterName: _hunter!.hunterName,
          level: _hunter!.level,
          currentXp: _hunter!.currentXp,
          nextLevelXp: _hunter!.nextLevelXp,
          currentCoins: _hunter!.currentCoins,

          currentHp: result['remainingHp'],
          maxHp: _hunter!.maxHp,
          currentStreak: _hunter!.currentStreak,

          strength: _hunter!.strength,
          dexterity: _hunter!.dexterity,
          intelligence: _hunter!.intelligence,
          constitution: _hunter!.constitution,
          endurance: _hunter!.endurance,
          attributePoints: _hunter!.attributePoints,
          damage: _hunter!.damage,
          defense: _hunter!.defense,
          xpDouble: _hunter!.xpDouble,
          equippedWeaponSlot: _hunter!.equippedWeaponSlot,
          equippedArmorSlot: _hunter!.equippedArmorSlot,
        );
      }

      _setError(null);

      return result['message'] ?? "Contrato abandonado.";
    } catch (e) {
      _setError(e.toString());
      return "Erro: $e";
    } finally {
      _setLoading(
        false,
      ); // Notifica a UI para redesenhar a barra de vida e a lista
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
