
enum StoreVisualType {
  standard,
  unlimited,
  stackedCoins,
  chest
}

enum StoreItemColorType {
  blue,
  purple,
  gold,
  goldDark
}

// --- DATA MODEL ---
class StoreItemData {
  final String id;
  final String? productId; // Pour les achats intégrés (Google Play / App Store)
  
  // Clés de localisation
  final String titleKey;
  final String? descriptionKey;
  final String? badgeTextKey;
  
  // Données d'affichage
  final String amount;
  final String price;
  
  // Configuration visuelle
  final String assetPath;
  final StoreVisualType visualType;
  final StoreItemColorType colorType;
  
  // Logic
  final int rewardValue; // Quantité de récompense (pièces) donnée lors de l'achat
  
  // Flags
  final bool isPopular;
  final bool isCurrencyPrice; // Utilise la monnaie virtuelle (pièces) au lieu de l'argent réel
  final double height;

  const StoreItemData({
    required this.id,
    this.productId,
    required this.titleKey,
    this.descriptionKey,
    required this.amount,
    required this.price,
    required this.assetPath,
    required this.colorType,
    this.visualType = StoreVisualType.standard,
    this.rewardValue = 0,
    this.isPopular = false,
    this.isCurrencyPrice = false,
    this.height = 180,
    this.badgeTextKey,
  });
}

// --- LISTES DE DONNÉES ---

// 1. CONSOMMABLES (Achat avec monnaie virtuelle)
final List<StoreItemData> consumableItems = [
  const StoreItemData(
    id: 'refill_lives',
    titleKey: 'campaign.store.refill_lives',
    amount: "FULL",
    price: "900",
    assetPath: 'assets/images/indicators/heart.png',
    colorType: StoreItemColorType.blue,
    isCurrencyPrice: true,
  ),
  const StoreItemData(
    id: 'unlimited_lives',
    titleKey: 'campaign.store.unlimited_lives',
    amount: "1h30",
    price: "1500",
    assetPath: 'assets/images/indicators/heart.png',
    colorType: StoreItemColorType.purple,
    visualType: StoreVisualType.unlimited,
    isCurrencyPrice: true,
    isPopular: true,
    badgeTextKey: 'campaign.store.best_badge',
  ),
];

// 2. PACKS DE PIÈCES (Achat avec argent réel)
final List<StoreItemData> coinPackItems = [
  const StoreItemData(
    id: 'coins_100',
    productId: 'word_train_coins_100',
    titleKey: "",
    amount: "+ 100",
    price: "0.99 €",
    rewardValue: 100,
    assetPath: 'assets/images/indicators/coin.png',
    colorType: StoreItemColorType.gold,
    height: 220,
  ),
  const StoreItemData(
    id: 'coins_500',
    productId: 'word_train_coins_500',
    titleKey: "",
    amount: "+ 500",
    price: "3.99 €",
    rewardValue: 500,
    assetPath: 'assets/images/indicators/coin.png',
    colorType: StoreItemColorType.gold,
    visualType: StoreVisualType.stackedCoins,
    height: 220,
  ),
  const StoreItemData(
    id: 'coins_2000',
    productId: 'word_train_coins_2000',
    titleKey: "",
    amount: "+ 2000",
    price: "9.99 €",
    rewardValue: 2000,
    assetPath: 'assets/images/indicators/chest_of_coins.png',
    colorType: StoreItemColorType.gold,
    visualType: StoreVisualType.chest,
    isPopular: true,
    badgeTextKey: 'campaign.store.best_badge',
    height: 220, 
  ),
];

// 3. OFFRES SPÉCIALES (Achat avec argent réel)
final List<StoreItemData> specialOfferItems = [
  const StoreItemData(
    id: 'no_ads',
    productId: 'word_train_no_ads',
    titleKey: 'campaign.store.no_ads_title',
    descriptionKey: 'campaign.store.no_ads_desc',
    amount: "∞",
    price: "4.99 €",
    assetPath: '', // Géré dynamiquement dans l'interface utilisateur en fonction de la langue pour cet élément
    colorType: StoreItemColorType.goldDark,
  ),
];
