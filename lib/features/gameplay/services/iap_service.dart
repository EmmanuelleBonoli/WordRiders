import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/data/store_data.dart';

// Service pour gérer les achats In-App (IAP)
class IapService {
  // IDs et Clés
  static String get noAdsProductId => specialOfferItems.firstWhere((i) => i.id == 'no_ads').productId!;
  static const String _keyNoAds = 'no_ads_purchased';

  // Instance IAP officielle
  // Instance IAP officielle (Nullable pour gérer les cas d'erreur/Web)
  static InAppPurchase? _iap;
  
  // État du service
  static bool _isStoreAvailable = false;
  static List<ProductDetails> _products = [];
  static final StreamController<String> _purchaseController = StreamController.broadcast();
  static Stream<String> get purchaseSuccessStream => _purchaseController.stream;
  
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Callback UI
  static Function(String message, bool isError)? onErrorOrSuccess;

  // Initialisation du service complet
  static Future<void> initialize() async {
    // Déterminer si on est sur une plateforme mobile supportée (Android/iOS)
    // Sur Web ou Desktop, on force _iap à null pour éviter les crashs
    bool isMobile = false;
    if (!kIsWeb) {
      try {
        isMobile = Platform.isAndroid || Platform.isIOS;
      } catch (_) {}
    }

    if (isMobile) {
      try {
        _iap = InAppPurchase.instance;
      } catch (e) {
        debugPrint("[IAP] Initialisation échouée : $e");
        _iap = null;
      }
    } else {
      _iap = null;
      debugPrint("[IAP] Plateforme non supportée (Web/Desktop). IAP désactivé.");
    }

    if (_iap != null) {
      // 1. Écouter le flux d'achats (Indispensable pour la prod : gère les achats en cours, interrompus, etc.)
      try {
        final purchaseUpdated = _iap!.purchaseStream;
        _subscription = purchaseUpdated.listen(
          _onPurchaseUpdate, 
          onDone: () => _subscription?.cancel(), 
          onError: (error) {
             debugPrint("[IAP] Erreur de stream : $error");
          },
        );

        // 2. Vérifier la disponibilité du Store (Google Play / App Store)
        _isStoreAvailable = await _iap!.isAvailable();
      } catch (e) {
        debugPrint("[IAP] Erreur lors de l'accès au store: $e");
        _isStoreAvailable = false;
      }
    } else {
      _isStoreAvailable = false;
    }

    if (_isStoreAvailable) {
      // --- MODE PRODUCTION ---
      debugPrint("[IAP] Store disponible. Chargement du catalogue officiel...");
      await _loadStoreProducts();
    } else {
      // --- MODE DÉVELOPPEMENT / DÉGRADÉ ---
      debugPrint("[IAP] Store indisponible.");
      
      // En mode Debug ou Web, on active le mode simulation pour pouvoir travailler
      if (kDebugMode || kIsWeb) {
        debugPrint("[IAP] Activation du mode SIMULATION (Bypass Dev).");
        _loadMockProducts();
      }
    }
  }

  // Chargement des vrais produits depuis le Store
  static Future<void> _loadStoreProducts() async {
    if (_iap == null) return;

    final Set<String> ids = {};
    for (final item in specialOfferItems) {
      if (item.productId != null) ids.add(item.productId!);
    }
    for (final item in coinPackItems) {
      if (item.productId != null) ids.add(item.productId!);
    }

    try {
      final response = await _iap!.queryProductDetails(ids);
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("[IAP Warning] IDs non trouvés dans le Store : ${response.notFoundIDs}");
      }
      
      _products = response.productDetails.toList();
      debugPrint("[IAP] ${_products.length} produits chargés officiellement.");
    } catch (e) {
      debugPrint("[IAP Error] Impossible de charger les produits : $e");
    }
  }

  // Réception des mises à jour d'achats
  static Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint("[IAP] Achat en attente... (${purchaseDetails.productID})");
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("[IAP] Échec de l'achat : ${purchaseDetails.error}");
          onErrorOrSuccess?.call("Échec de la transaction", true);
        } else if (purchaseDetails.status == PurchaseStatus.purchased || 
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          debugPrint("[IAP] Transaction réussie : ${purchaseDetails.productID}");
          
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverProduct(purchaseDetails);
            
            // INDISPENSABLE : Marquer la transaction comme terminée pour ne pas être re-livré
            if (purchaseDetails.pendingCompletePurchase && _iap != null) {
              await _iap!.completePurchase(purchaseDetails);
            }
          }
        }
      }
    }
  }

  // Logique métier : Donner la récompense à l'utilisateur
  static Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final id = purchaseDetails.productID;
    
    // Identifier l'item correspondant dans nos données locales (store_data)
    StoreItemData? matchedItem;
    final allItems = [...specialOfferItems, ...coinPackItems];
    try {
      matchedItem = allItems.firstWhere((item) => item.productId == id);
    } catch (_) {}

    if (matchedItem != null) {
      // Cas 1 : No Ads
      if (matchedItem.id == 'no_ads' || id == noAdsProductId) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyNoAds, true);
        onErrorOrSuccess?.call("Publicités supprimées à vie !", false);
      } 
      // Cas 2 : Pièces
      else if (matchedItem.rewardValue > 0) {
        await PlayerPreferences.addCoins(matchedItem.rewardValue);
        onErrorOrSuccess?.call("+${matchedItem.rewardValue} Pièces !", false);
      }
      
      // Notifier tout le monde du succès (No Ads ou Pièces)
      _purchaseController.add(id);
    } else {
      debugPrint("[IAP Error] Produit acheté non reconnu dans store_data : $id");
    }
  }

  // Vérification de la transaction
  static Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // NOTE : Pour une sécurité maximale, c'est ici qu'on envoie purchaseDetails.verificationData
    // à un serveur backend pour validation auprès de Google/Apple.
    // Pour une app "Serverless" comme celle-ci, on accepte la transaction locale comme valide.
    return true; 
  }

  // --- ACTIONS PUBLIQUES ---

  static List<ProductDetails> get products => _products;
  
  static ProductDetails? getProductById(String id) {
     try {
       return _products.firstWhere((p) => p.id == id);
     } catch (e) {
       return null;
     }
  }

  // Lancer un achat
  static Future<void> buy(ProductDetails product) async {
    // Bypass Simulation (Dev seulement, si store cassé ou Web)
    if (!_isStoreAvailable && (kDebugMode || kIsWeb)) {
      _simulatePurchase(product.id);
      return;
    }

    if (!_isStoreAvailable || _iap == null) {
      onErrorOrSuccess?.call("Boutique indisponible", true);
      return;
    }

    // Achat Réel
    final purchaseParam = PurchaseParam(productDetails: product);
    
    if (product.id == noAdsProductId) {
      // Non-consommable (Unique)
      await _iap!.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      // Consommable (Répétable)
      await _iap!.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
    }
  }

  static Future<void> restorePurchases() async {
    if (_isStoreAvailable && _iap != null) {
      await _iap!.restorePurchases();
    } else if (kDebugMode) {
       // Simulation de restauration en dev
       onErrorOrSuccess?.call("Restauration simulée (Dev)", false);
    }
  }

  static Future<bool> isNoAdsPurchased() async {
     // Vérification locale (cache) - C'est la méthode standard pour vérifier rapidement au démarrage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNoAds) ?? false;
  }

  static void dispose() {
    _subscription?.cancel();
  }

  // --- MOCK / SIMULATION (Uniquement utilisé si Store absent en Dev) ---
  
  static void _loadMockProducts() {
    _products = [];
    for (final item in [...specialOfferItems, ...coinPackItems]) {
      if (item.productId == null) continue;
      _products.add(ProductDetails(
        id: item.productId!,
        title: item.amount,
        description: 'Simulation Dev',
        price: item.price,
        rawPrice: 0.99,
        currencyCode: 'EUR',
      ));
    }
  }

  static Future<void> _simulatePurchase(String productId) async {
    debugPrint("[IAP Simulation] Achat réussi pour $productId");
    // On crée un faux détail d'achat et on le passe directement au système de livraison
    final details = PurchaseDetails(
       purchaseID: 'sim_${DateTime.now().millisecondsSinceEpoch}',
       productID: productId,
       verificationData: PurchaseVerificationData(localVerificationData: '', serverVerificationData: '', source: 'simulation'),
       transactionDate: DateTime.now().toString(),
       status: PurchaseStatus.purchased,
    );
    await _deliverProduct(details);
  }
}
