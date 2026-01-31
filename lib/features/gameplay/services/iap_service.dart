import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer les achats In-App (IAP) via Apple Play Store / Google Play Store
class IapService {
  static const String noAdsProductId = 'no_ads_permanent'; // À configurer dans les consoles Store
  static const String _keyNoAds = 'no_ads_purchased';

  static final InAppPurchase _iap = InAppPurchase.instance;
  static bool _available = false;
  static List<ProductDetails> _products = [];

  /// Initialise le service IAP
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('IAP: Web detected, skipping InAppPurchase initialization.');
      _available = false;
      return;
    }
    _available = await _iap.isAvailable();
    if (_available) {
      const Set<String> ids = {noAdsProductId};
      final response = await _iap.queryProductDetails(ids);
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IAP: Produits non trouvés: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails.toList();
      debugPrint('IAP: ${_products.length} produits chargés.');
    } else {
      debugPrint('IAP: Store non disponible.');
    }
  }

  /// Vérifie si le statut "No Ads" est déjà possédé localement
  static Future<bool> isNoAdsPurchased() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNoAds) ?? false;
  }

  /// Récupère les détails du produit No Ads (prix localisé, etc.)
  static ProductDetails? getNoAdsProduct() {
    if (_products.isEmpty) return null;
    for (final product in _products) {
      if (product.id == noAdsProductId) return product;
    }
    return _products.first;
  }

  /// Lance le processus d'achat
  static Future<bool> buyNoAds() async {
    if (!_available) {
      debugPrint('IapService: Store non disponible pour le moment.');
      return false;
    }

    // Dans une application réelle, on écouterait le flux d'achat via InAppPurchase.instance.purchaseStream
    // Pour cet environnement, nous simulons la réussite de la transaction native.
    
    debugPrint('IAP: Lancement de l\'achat pour $noAdsProductId (4,99€)...');
    
    // Simulation d'une attente réseau/store
    await Future.delayed(const Duration(seconds: 2));

    // Sauvegarde locale de la validation (normalement faite après réception d'un PurchaseDetails validé)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNoAds, true);
    
    debugPrint('IAP: Achat réussi et enregistré.');
    return true;
  }

  /// Restaure les achats (indispensable pour iOS)
  static Future<void> restorePurchases() async {
    if (!_available) return;
    
    // Sur iOS, on appellerait : await _iap.restorePurchases();
    // Ici nous simulons que si l'achat existait, on le remet à true.
    debugPrint('IAP: Restauration des achats...');
    await Future.delayed(const Duration(seconds: 1));
  }
}
