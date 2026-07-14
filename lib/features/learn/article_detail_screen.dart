import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/learn_article.dart';

class ArticleDetailScreen extends StatelessWidget {
  final LearnArticle article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(article.category)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(article.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '${article.readMinutes} ${strings('minRead')}',
            style: const TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Text(article.body, style: const TextStyle(fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }
}
