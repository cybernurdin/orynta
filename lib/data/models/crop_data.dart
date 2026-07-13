class CropData {
  final String id;
  final String name;
  final String category; // 'vegetable', 'grain', 'fruit', 'legume', 'root_crop', 'cash_crop'
  final String? imageUrl;
  final String bestSoilType;
  final double optimalPh; // e.g., 6.5
  final double minTemp; // Celsius
  final double maxTemp;
  final String plantingMonth;
  final String harvestMonth;
  final int daysToMaturity;
  final double optimalMoisture; // percentage
  final String plantingGuide;
  final List<String> companionPlants;
  final List<String> pestsAndDiseases;
  final List<String> wateringSchedule;
  final String? nutritionalBenefit;

  CropData({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.bestSoilType,
    required this.optimalPh,
    required this.minTemp,
    required this.maxTemp,
    required this.plantingMonth,
    required this.harvestMonth,
    required this.daysToMaturity,
    required this.optimalMoisture,
    required this.plantingGuide,
    required this.companionPlants,
    required this.pestsAndDiseases,
    required this.wateringSchedule,
    this.nutritionalBenefit,
  });

  factory CropData.fromJson(Map<String, dynamic> json) {
    return CropData(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      bestSoilType: json['bestSoilType'] as String,
      optimalPh: (json['optimalPh'] as num).toDouble(),
      minTemp: (json['minTemp'] as num).toDouble(),
      maxTemp: (json['maxTemp'] as num).toDouble(),
      plantingMonth: json['plantingMonth'] as String,
      harvestMonth: json['harvestMonth'] as String,
      daysToMaturity: json['daysToMaturity'] as int,
      optimalMoisture: (json['optimalMoisture'] as num).toDouble(),
      plantingGuide: json['plantingGuide'] as String,
      companionPlants: List<String>.from(json['companionPlants'] as List),
      pestsAndDiseases: List<String>.from(json['pestsAndDiseases'] as List),
      wateringSchedule: List<String>.from(json['wateringSchedule'] as List),
      nutritionalBenefit: json['nutritionalBenefit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'bestSoilType': bestSoilType,
      'optimalPh': optimalPh,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'plantingMonth': plantingMonth,
      'harvestMonth': harvestMonth,
      'daysToMaturity': daysToMaturity,
      'optimalMoisture': optimalMoisture,
      'plantingGuide': plantingGuide,
      'companionPlants': companionPlants,
      'pestsAndDiseases': pestsAndDiseases,
      'wateringSchedule': wateringSchedule,
      'nutritionalBenefit': nutritionalBenefit,
    };
  }
}

// Cameroon Crops Database
class CameruCropsDatabase {
  static final List<CropData> cropsData = [
    // Vegetables
    CropData(
      id: 'tomato',
      name: 'Tomato',
      category: 'vegetable',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.5,
      minTemp: 16,
      maxTemp: 32,
      plantingMonth: 'February-September',
      harvestMonth: 'May-December',
      daysToMaturity: 80,
      optimalMoisture: 60,
      plantingGuide:
          'Start seeds indoors 6-8 weeks before last frost. Transplant when seedlings have 2-4 true leaves. Requires full sun and well-draining soil.',
      companionPlants: ['Basil', 'Parsley', 'Carrot'],
      pestsAndDiseases: ['Aphids', 'Whiteflies', 'Early blight', 'Late blight'],
      wateringSchedule: ['Regular watering, 1-2 inches per week'],
      nutritionalBenefit: 'Rich in vitamin C and lycopene',
    ),
    CropData(
      id: 'lettuce',
      name: 'Lettuce',
      category: 'vegetable',
      bestSoilType: 'Clay loam',
      optimalPh: 6.5,
      minTemp: 10,
      maxTemp: 24,
      plantingMonth: 'January-September',
      harvestMonth: 'February-October',
      daysToMaturity: 45,
      optimalMoisture: 70,
      plantingGuide:
          'Direct seed or transplant seedlings. Prefers cool weather. Keep soil consistently moist. Thin seedlings to prevent overcrowding.',
      companionPlants: ['Carrot', 'Radish', 'Strawberry'],
      pestsAndDiseases: ['Slugs', 'Aphids', 'Powdery mildew'],
      wateringSchedule: ['Keep soil moist, not waterlogged'],
      nutritionalBenefit: 'Good source of vitamins A and K',
    ),
    CropData(
      id: 'pepper',
      name: 'Bell Pepper',
      category: 'vegetable',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.5,
      minTemp: 18,
      maxTemp: 30,
      plantingMonth: 'March-August',
      harvestMonth: 'June-November',
      daysToMaturity: 90,
      optimalMoisture: 65,
      plantingGuide:
          'Start from seeds indoors 8-10 weeks before transplanting. Needs warm temperatures. Space plants 18-24 inches apart.',
      companionPlants: ['Onion', 'Tomato', 'Basil'],
      pestsAndDiseases: ['Aphids', 'Spider mites', 'Anthracnose'],
      wateringSchedule: ['Deep watering 2-3 times per week'],
      nutritionalBenefit: 'High in vitamin C',
    ),
    CropData(
      id: 'cabbage',
      name: 'Cabbage',
      category: 'vegetable',
      bestSoilType: 'Laterite',
      optimalPh: 6.5,
      minTemp: 12,
      maxTemp: 26,
      plantingMonth: 'February-August',
      harvestMonth: 'May-November',
      daysToMaturity: 85,
      optimalMoisture: 70,
      plantingGuide:
          'Start from seeds or seedlings. Transplant when 5-6 weeks old. Requires rich soil with good drainage. Hill soil around plants.',
      companionPlants: ['Beet', 'Onion', 'Dill'],
      pestsAndDiseases: ['Cabbage worm', 'Clubroot', 'Black rot'],
      wateringSchedule: ['Consistent moisture, 1-2 inches per week'],
      nutritionalBenefit: 'Rich in vitamin C and fiber',
    ),
    CropData(
      id: 'spinach',
      name: 'Spinach',
      category: 'vegetable',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.8,
      minTemp: 8,
      maxTemp: 22,
      plantingMonth: 'January-March, August-October',
      harvestMonth: 'March-May, October-December',
      daysToMaturity: 40,
      optimalMoisture: 65,
      plantingGuide:
          'Direct seed into soil. Thin seedlings to 4-6 inches apart. Prefers cool weather. Can be harvested as baby spinach.',
      companionPlants: ['Strawberry', 'Radish', 'Tomato'],
      pestsAndDiseases: ['Aphids', 'Leaf miner', 'Powdery mildew'],
      wateringSchedule: ['Keep soil consistently moist'],
      nutritionalBenefit: 'Excellent source of iron and calcium',
    ),
    CropData(
      id: 'okra',
      name: 'Okra',
      category: 'vegetable',
      bestSoilType: 'Laterite',
      optimalPh: 6.5,
      minTemp: 20,
      maxTemp: 35,
      plantingMonth: 'April-July',
      harvestMonth: 'July-October',
      daysToMaturity: 60,
      optimalMoisture: 60,
      plantingGuide:
          'Direct seed after last frost. Space plants 12-18 inches apart. Thrives in hot weather. Harvest pods when young and tender.',
      companionPlants: ['Corn', 'Melon', 'Eggplant'],
      pestsAndDiseases: ['Stem borers', 'Yellow mosaic virus', 'Powdery mildew'],
      wateringSchedule: ['Regular watering during flowering'],
      nutritionalBenefit: 'Good source of vitamins and minerals',
    ),

    // Grains & Cereals
    CropData(
      id: 'maize',
      name: 'Maize (Corn)',
      category: 'grain',
      bestSoilType: 'Laterite',
      optimalPh: 6.5,
      minTemp: 16,
      maxTemp: 32,
      plantingMonth: 'March-May, September-November',
      harvestMonth: 'July-September, January-March',
      daysToMaturity: 120,
      optimalMoisture: 60,
      plantingGuide:
          'Direct seed after frost danger. Space rows 75cm apart, seeds 20cm apart. Requires fertile, well-draining soil. Support tall varieties.',
      companionPlants: ['Bean', 'Pumpkin', 'Melon'],
      pestsAndDiseases: ['Fall armyworm', 'Corn borer', 'Leaf blight'],
      wateringSchedule: ['1-2 inches per week, especially during tasseling'],
      nutritionalBenefit: 'Staple carbohydrate source',
    ),
    CropData(
      id: 'rice',
      name: 'Rice',
      category: 'grain',
      bestSoilType: 'Clay loam',
      optimalPh: 6.0,
      minTemp: 18,
      maxTemp: 32,
      plantingMonth: 'May-June',
      harvestMonth: 'September-October',
      daysToMaturity: 150,
      optimalMoisture: 80,
      plantingGuide:
          'Can be grown in wetland or upland conditions. Requires flooding for lowland varieties. Needs 6-8 weeks nursery period.',
      companionPlants: [],
      pestsAndDiseases: ['Rice blast', 'Brown planthopper', 'Gall midge'],
      wateringSchedule: ['Maintain 5cm water depth for flooded rice'],
      nutritionalBenefit: 'Primary staple grain',
    ),
    CropData(
      id: 'sorghum',
      name: 'Sorghum',
      category: 'grain',
      bestSoilType: 'Laterite',
      optimalPh: 6.5,
      minTemp: 16,
      maxTemp: 35,
      plantingMonth: 'April-June',
      harvestMonth: 'August-October',
      daysToMaturity: 110,
      optimalMoisture: 50,
      plantingGuide:
          'Direct seeding preferred. Space rows 60-75cm apart. Drought tolerant. Requires minimal fertilizer.',
      companionPlants: [],
      pestsAndDiseases: ['Shoot fly', 'Midge', 'Leaf blight'],
      wateringSchedule: ['Minimal water needed, drought resistant'],
      nutritionalBenefit: 'Gluten-free grain',
    ),

    // Legumes
    CropData(
      id: 'groundnut',
      name: 'Groundnut (Peanut)',
      category: 'legume',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.5,
      minTemp: 18,
      maxTemp: 32,
      plantingMonth: 'April-June',
      harvestMonth: 'August-October',
      daysToMaturity: 120,
      optimalMoisture: 55,
      plantingGuide:
          'Direct seed in warm soil. Space rows 45cm apart, seeds 20cm. Needs well-draining soil. Mulch to retain moisture.',
      companionPlants: ['Maize', 'Millet'],
      pestsAndDiseases: ['Aflatoxin', 'Leaf spot', 'Root rot'],
      wateringSchedule: ['Regular watering during pod formation'],
      nutritionalBenefit: 'Rich in protein and healthy oils',
    ),
    CropData(
      id: 'cowpea',
      name: 'Cowpea',
      category: 'legume',
      bestSoilType: 'Laterite',
      optimalPh: 6.5,
      minTemp: 18,
      maxTemp: 32,
      plantingMonth: 'May-July',
      harvestMonth: 'August-October',
      daysToMaturity: 90,
      optimalMoisture: 60,
      plantingGuide:
          'Direct seed or transplant seedlings. Space rows 45cm apart. Nitrogen-fixing crop, improves soil. Can be intercropped.',
      companionPlants: ['Maize', 'Sorghum'],
      pestsAndDiseases: ['Pod borers', 'Leaf beetles', 'Viral diseases'],
      wateringSchedule: ['Moderate watering'],
      nutritionalBenefit: 'High in protein',
    ),
    CropData(
      id: 'bean',
      name: 'Bean',
      category: 'legume',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.5,
      minTemp: 16,
      maxTemp: 30,
      plantingMonth: 'March-August',
      harvestMonth: 'June-November',
      daysToMaturity: 80,
      optimalMoisture: 60,
      plantingGuide:
          'Direct seed after frost. Space rows 45cm, seeds 8-10cm apart. Provide trellising for climbing varieties. Mulch soil.',
      companionPlants: ['Corn', 'Squash', 'Carrot'],
      pestsAndDiseases: ['Bean beetles', 'Rust', 'Anthracnose'],
      wateringSchedule: ['1-2 inches per week'],
      nutritionalBenefit: 'Protein and fiber rich',
    ),

    // Root Crops
    CropData(
      id: 'cassava',
      name: 'Cassava',
      category: 'root_crop',
      bestSoilType: 'Laterite',
      optimalPh: 6.5,
      minTemp: 18,
      maxTemp: 32,
      plantingMonth: 'April-June',
      harvestMonth: 'January-March',
      daysToMaturity: 360,
      optimalMoisture: 55,
      plantingGuide:
          'Propagated from stem cuttings. Space plants 1m x 1m. Requires minimal care. Harvest when leaves start to yellow.',
      companionPlants: [],
      pestsAndDiseases: ['Cassava mosaic virus', 'Mites', 'Root rot'],
      wateringSchedule: ['Minimal, established plants are drought tolerant'],
      nutritionalBenefit: 'Carbohydrate staple',
    ),
    CropData(
      id: 'yam',
      name: 'Yam',
      category: 'root_crop',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.5,
      minTemp: 18,
      maxTemp: 30,
      plantingMonth: 'March-April',
      harvestMonth: 'December-February',
      daysToMaturity: 240,
      optimalMoisture: 70,
      plantingGuide:
          'Plant seed yams 15cm deep, spaced 1-1.2m apart. Requires staking and mulching. Needs good drainage.',
      companionPlants: [],
      pestsAndDiseases: ['Anthracnose', 'Nematodes', 'Viruses'],
      wateringSchedule: ['Regular watering during growing season'],
      nutritionalBenefit: 'Nutritious root vegetable',
    ),
    CropData(
      id: 'potato',
      name: 'Potato',
      category: 'root_crop',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.5,
      minTemp: 10,
      maxTemp: 24,
      plantingMonth: 'February-April, September-November',
      harvestMonth: 'May-July, December-January',
      daysToMaturity: 90,
      optimalMoisture: 70,
      plantingGuide:
          'Plant seed potatoes 15cm deep. Hoe to cover plants as they grow. Keep soil moist. Harvest when foliage dies back.',
      companionPlants: ['Bean', 'Corn', 'Pea'],
      pestsAndDiseases: ['Late blight', 'Early blight', 'Colorado beetle'],
      wateringSchedule: ['1-2 inches per week'],
      nutritionalBenefit: 'Carbohydrate and vitamin source',
    ),

    // Fruits
    CropData(
      id: 'banana',
      name: 'Banana',
      category: 'fruit',
      bestSoilType: 'Laterite',
      optimalPh: 6.0,
      minTemp: 18,
      maxTemp: 30,
      plantingMonth: 'Year-round',
      harvestMonth: 'Year-round',
      daysToMaturity: 270,
      optimalMoisture: 70,
      plantingGuide:
          'Plant suckers with 1-2 leaves. Space 3m apart. Needs mulching and support. Remove dead leaves and pests.',
      companionPlants: [],
      pestsAndDiseases: ['Panama disease', 'Sigatoka', 'Weevils'],
      wateringSchedule: ['Regular watering, 2.5-5cm per week'],
      nutritionalBenefit: 'Rich in potassium',
    ),
    CropData(
      id: 'avocado',
      name: 'Avocado',
      category: 'fruit',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.5,
      minTemp: 16,
      maxTemp: 28,
      plantingMonth: 'Year-round',
      harvestMonth: 'Year-round',
      daysToMaturity: 365,
      optimalMoisture: 60,
      plantingGuide:
          'Plant from seedlings or grafted trees. Needs well-draining soil. Space 8-10m apart. Minimal pruning required.',
      companionPlants: [],
      pestsAndDiseases: ['Root rot', 'Anthracnose', 'Mites'],
      wateringSchedule: ['Deep watering, every 1-2 weeks'],
      nutritionalBenefit: 'Healthy fats and nutrients',
    ),
    CropData(
      id: 'papaya',
      name: 'Papaya',
      category: 'fruit',
      bestSoilType: 'Laterite',
      optimalPh: 6.5,
      minTemp: 18,
      maxTemp: 32,
      plantingMonth: 'March-July',
      harvestMonth: 'September-December',
      daysToMaturity: 365,
      optimalMoisture: 60,
      plantingGuide:
          'Direct seed or use seedlings. Space 2-3m apart. Needs good drainage. Female and male trees required for fruit.',
      companionPlants: [],
      pestsAndDiseases: ['Ring spot virus', 'Leaf spot', 'Stem canker'],
      wateringSchedule: ['Moderate watering, more in dry season'],
      nutritionalBenefit: 'Rich in vitamin C',
    ),
    CropData(
      id: 'citrus',
      name: 'Orange (Citrus)',
      category: 'fruit',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.5,
      minTemp: 12,
      maxTemp: 28,
      plantingMonth: 'Year-round',
      harvestMonth: 'Year-round',
      daysToMaturity: 365,
      optimalMoisture: 65,
      plantingGuide:
          'Plant grafted trees for faster production. Space 5-7m apart. Prune for shape and air circulation.',
      companionPlants: [],
      pestsAndDiseases: ['Citrus canker', 'Fruit flies', 'Scale insects'],
      wateringSchedule: ['Regular watering, especially during fruiting'],
      nutritionalBenefit: 'High in vitamin C',
    ),

    // Cash Crops
    CropData(
      id: 'cocoa',
      name: 'Cocoa',
      category: 'cash_crop',
      bestSoilType: 'Laterite',
      optimalPh: 6.5,
      minTemp: 18,
      maxTemp: 32,
      plantingMonth: 'Year-round',
      harvestMonth: 'May-August, October-December',
      daysToMaturity: 1095, // 3 years
      optimalMoisture: 70,
      plantingGuide:
          'Requires shade trees. Plant 3m x 3m spacing. Needs 6-8 years for full production. Regular pruning essential.',
      companionPlants: [],
      pestsAndDiseases: ['Frosty pod rot', 'Black pod', 'Cocoa swollen shoot'],
      wateringSchedule: ['Well-distributed rainfall needed'],
      nutritionalBenefit: 'Valuable commodity crop',
    ),
    CropData(
      id: 'coffee',
      name: 'Coffee',
      category: 'cash_crop',
      bestSoilType: 'Laterite',
      optimalPh: 6.5,
      minTemp: 15,
      maxTemp: 24,
      plantingMonth: 'Year-round',
      harvestMonth: 'December-February',
      daysToMaturity: 1095, // 3 years
      optimalMoisture: 65,
      plantingGuide:
          'Prefers highland areas (800-2000m). Space 1.5-2m apart. Requires shade and regular pruning.',
      companionPlants: [],
      pestsAndDiseases: ['Coffee berry disease', 'Leaf rust', 'Coffee wilt'],
      wateringSchedule: ['Well-distributed moisture'],
      nutritionalBenefit: 'Valuable beverage crop',
    ),
    CropData(
      id: 'rubber',
      name: 'Rubber Tree',
      category: 'cash_crop',
      bestSoilType: 'Sandy loam',
      optimalPh: 6.5,
      minTemp: 18,
      maxTemp: 32,
      plantingMonth: 'Year-round',
      harvestMonth: 'Year-round',
      daysToMaturity: 2190, // 6 years
      optimalMoisture: 70,
      plantingGuide:
          'Needs high rainfall and humidity. Space 4-6m apart. First tapping at 5-6 years. Requires disease management.',
      companionPlants: [],
      pestsAndDiseases: ['South American leaf blight', 'Root rot', 'Powder mildew'],
      wateringSchedule: ['Regular rainfall needed'],
      nutritionalBenefit: 'Industrial commodity',
    ),
  ];

  static CropData? getCropById(String id) {
    try {
      return cropsData.firstWhere((crop) => crop.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<CropData> getCropsByCategory(String category) {
    return cropsData.where((crop) => crop.category == category).toList();
  }

  static List<CropData> searchCrops(String query) {
    final lowerQuery = query.toLowerCase();
    return cropsData
        .where((crop) =>
            crop.name.toLowerCase().contains(lowerQuery) ||
            crop.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  static List<String> getAllCategories() {
    return cropsData.map((crop) => crop.category).toSet().toList();
  }
}
