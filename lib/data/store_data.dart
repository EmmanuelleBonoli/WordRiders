
enum StoreVisualType {
  standard,
  unlimited,
  stackedCoins,
  chest,
  bonus,
  bonusUnlimited
}

enum StoreItemColorType {
  blue,
  gold,
  goldDark
}

// --- DATA MODEL ---
class StoreItemData {
  final String id;
  final String? productId; // Pour les achats intégrés (Google Play / App Store)
  
  // Clés de localisation
  final String descriptionKey;
  final String? extendedDescriptionKey;
  final String? badgeTextKey;
  
  // Données d'affichage
  final String title;
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
    required this.descriptionKey,
    this.extendedDescriptionKey,
    required this.title,
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
    descriptionKey: 'campaign.store.refill_lives',
    title: "FULL",
    price: "900",
    assetPath: 'assets/images/indicators/heart.png',
    colorType: StoreItemColorType.blue,
    isCurrencyPrice: true,
  ),
  const StoreItemData(
    id: 'unlimited_lives',
    descriptionKey: 'campaign.store.unlimited_lives',
    title: "1h30",
    price: "1500",
    assetPath: 'assets/images/indicators/heart.png',
    colorType: StoreItemColorType.blue,
    visualType: StoreVisualType.unlimited,
    isCurrencyPrice: true,
    isPopular: true,
    badgeTextKey: 'campaign.store.best_badge',
  ),
  const StoreItemData(
    id: 'bonus_pack_1',
    descriptionKey: '',
    title: "Bonus",
    price: "800",
    assetPath: '',
    colorType: StoreItemColorType.blue,
    visualType: StoreVisualType.bonus,
    isCurrencyPrice: true,
  ),
  const StoreItemData(
    id: 'bonus_pack_unlimited',
    descriptionKey: '',
    title: "Bonus +",
    price: "2500",
    assetPath: '',
    colorType: StoreItemColorType.blue,
    visualType: StoreVisualType.bonusUnlimited,
    isCurrencyPrice: true,
  ),
];

// 2. PACKS DE PIÈCES (Achat avec argent réel)
final List<StoreItemData> coinPackItems = [
  const StoreItemData(
    id: 'coins_100',
    productId: 'word_riders_coins_100',
    descriptionKey: "",
    title: "+ 100",
    price: "0.99 €",
    rewardValue: 100,
    assetPath: 'assets/images/indicators/coin.png',
    colorType: StoreItemColorType.gold,
    height: 220,
  ),
  const StoreItemData(
    id: 'coins_500',
    productId: 'word_riders_coins_500',
    descriptionKey: "",
    title: "+ 500",
    price: "3.99 €",
    rewardValue: 500,
    assetPath: 'assets/images/indicators/coin.png',
    colorType: StoreItemColorType.gold,
    visualType: StoreVisualType.stackedCoins,
    height: 220,
  ),
  const StoreItemData(
    id: 'coins_2000',
    productId: 'word_riders_coins_2000',
    descriptionKey: "",
    title: "+ 2000",
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
    productId: 'word_riders_no_ads',
    descriptionKey: 'campaign.store.no_ads_title',
    extendedDescriptionKey: 'campaign.store.no_ads_desc',
    title: "∞",
    price: "4.99 €",
    assetPath: '', // Géré dynamiquement dans l'interface utilisateur en fonction de la langue pour cet élément
    colorType: StoreItemColorType.goldDark,
  ),
];
