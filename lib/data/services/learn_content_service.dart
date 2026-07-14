import '../models/learn_article.dart';

/// Static Learn & Resources content, seeded so the hub never looks empty.
/// Same pattern as [PlantingGuideService] — swap the body for a real
/// content API later without touching callers.
class LearnContentService {
  static const List<LearnArticle> _articles = [
    LearnArticle(
      id: 'learn_soil_health',
      title: 'Reading your soil health score',
      category: 'Soil',
      summary: 'What the health score, pH, and nutrient percentages from a soil scan actually mean.',
      body:
          'Your soil health score blends fertility, pH balance, and nutrient levels into a single number out of 100. '
          'A score above 70 generally means the soil is ready for planting with normal input levels. Scores between '
          '40 and 70 usually call for a targeted amendment — lime for low pH, compost or fertilizer for low nutrients. '
          'Below 40, plan a full soil improvement cycle (organic matter, cover cropping, or fallowing) before investing '
          'heavily in a new crop.',
      readMinutes: 4,
    ),
    LearnArticle(
      id: 'learn_composting',
      title: 'Building a simple compost pile',
      category: 'Soil',
      summary: 'Turn crop residue and kitchen scraps into free, effective fertilizer.',
      body:
          'Layer dry material (straw, dried leaves) with green material (crop residue, vegetable scraps) in roughly '
          'equal parts. Keep the pile as moist as a wrung-out sponge and turn it every 1–2 weeks to add oxygen. In '
          '6–10 weeks in a warm climate, you should have dark, crumbly compost ready to work into your soil before '
          'the next planting.',
      readMinutes: 3,
    ),
    LearnArticle(
      id: 'learn_pest_id',
      title: 'Spotting common pests before they spread',
      category: 'Pest control',
      summary: 'Early signs of fall armyworm, aphids, and whiteflies — and what to do first.',
      body:
          'Check the underside of leaves and the whorl of young plants weekly. Fall armyworm leaves ragged holes and '
          'sawdust-like frass in maize whorls. Aphids cluster on new growth and leave a sticky residue. Whiteflies '
          'scatter in a small cloud when you shake a leaf. Catching any of these in the first week dramatically '
          'reduces the treatment needed compared to waiting until damage is visible from a distance.',
      readMinutes: 4,
    ),
    LearnArticle(
      id: 'learn_water_conservation',
      title: 'Getting more crop per drop',
      category: 'Water',
      summary: 'Mulching, timing, and spacing techniques that cut water use without cutting yield.',
      body:
          'Water early morning or late evening to reduce evaporation loss. A 5–10cm mulch layer around plants can cut '
          'watering frequency significantly by keeping soil moisture in. Group plants with similar water needs '
          'together so you are not over- or under-watering parts of the same bed, and prioritize water at flowering '
          'and fruit-set — the stages most sensitive to drought stress.',
      readMinutes: 3,
    ),
    LearnArticle(
      id: 'learn_post_harvest',
      title: 'Reducing post-harvest losses',
      category: 'Harvest',
      summary: 'Simple storage and handling changes that protect the harvest you already worked for.',
      body:
          'Harvest in the cooler part of the day to reduce field heat before storage. Sort out damaged or diseased '
          'produce immediately — one bad item speeds spoilage of everything around it. Store grains only once fully '
          'dry (bite-test or moisture meter), in a cool, rodent-proof container, off the ground and away from direct '
          'sunlight.',
      readMinutes: 3,
    ),
    LearnArticle(
      id: 'learn_intercropping',
      title: 'Intercropping for better land use',
      category: 'Crop planning',
      summary: 'Pairing crops like maize and beans to improve soil and reduce risk.',
      body:
          'Intercropping a grain with a legume (maize with beans or groundnut, for example) lets the legume fix '
          'nitrogen in the soil while the grain provides structure. Beyond the soil benefit, growing two crops on the '
          'same plot spreads your risk — a pest or price drop affecting one crop does not wipe out your whole '
          'season.',
      readMinutes: 3,
    ),
    LearnArticle(
      id: 'learn_dry_season_prep',
      title: 'Preparing land in the dry season',
      category: 'Crop planning',
      summary: 'What to do before the rains so you are ready to plant on day one.',
      body:
          'Clear and lightly till land while it is dry to make weeding easier once rains start. Apply lime now if '
          'your last soil scan showed low pH — it needs weeks to work into the soil before planting. Repair terraces '
          'or drainage channels before heavy rain arrives, and pre-order seed and fertilizer so a supply shortage '
          'does not delay planting once conditions are right.',
      readMinutes: 3,
    ),
    LearnArticle(
      id: 'learn_record_keeping',
      title: 'Why a simple planting log pays off',
      category: 'Crop planning',
      summary: 'Tracking what you planted, when, and how it performed makes every season easier than the last.',
      body:
          'A one-line-per-plot log — crop, planting date, input applied, yield — takes a minute to update but pays '
          'off within a year. It makes crop rotation decisions obvious, shows which fields consistently underperform '
          'and need soil work, and gives you real numbers to plan input purchases around instead of guessing each '
          'season.',
      readMinutes: 2,
    ),
  ];

  Future<List<LearnArticle>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _articles;
  }
}
