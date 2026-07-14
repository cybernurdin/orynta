import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/learn_article.dart';
import '../../data/services/learn_content_service.dart';
import 'article_detail_screen.dart';
import 'planting_guide_screen.dart';

/// Learn & Resources hub — the planting calendar (kept as-is, reached from
/// here) plus a library of short agronomy articles.
class LearnHomeScreen extends StatefulWidget {
  const LearnHomeScreen({super.key});

  @override
  State<LearnHomeScreen> createState() => _LearnHomeScreenState();
}

class _LearnHomeScreenState extends State<LearnHomeScreen> {
  final LearnContentService _service = LearnContentService();
  List<LearnArticle> _articles = [];

  @override
  void initState() {
    super.initState();
    _service.getAll().then((articles) {
      if (mounted) setState(() => _articles = articles);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings('learnResources'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(title: strings('plantingCalendarSection')),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const IconCircle(icon: Icons.calendar_month_rounded, background: AppColors.forest),
              title: Text(strings('plantingGuide'), style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(strings('plantingCalendarDesc'), style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlantingGuideScreen()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: strings('articlesAndTips')),
          const SizedBox(height: 10),
          if (_articles.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else
            ..._articles.map(
              (article) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const IconCircle(icon: Icons.menu_book_rounded, background: AppColors.amber),
                  title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  trailing: Text(
                    '${article.readMinutes} ${strings('minRead')}',
                    style: const TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
