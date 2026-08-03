import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

class SkeletonCategoryGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const SkeletonCategoryGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlightColor =
        isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.1,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(18.0),
            ),
          );
        },
      ),
    );
  }
}

class SkeletonItemList extends StatelessWidget {
  final int itemCount;

  const SkeletonItemList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlightColor =
        isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            height: 120.0,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
          );
        },
      ),
    );
  }
}

class SkeletonDetailView extends StatelessWidget {
  const SkeletonDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlightColor =
        isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 32, width: 220, color: baseColor),
            const SizedBox(height: 16),
            Container(height: 1, width: double.infinity, color: baseColor),
            const SizedBox(height: 24),
            Container(height: 18, width: double.infinity, color: baseColor),
            const SizedBox(height: 10),
            Container(height: 18, width: double.infinity, color: baseColor),
            const SizedBox(height: 10),
            Container(height: 18, width: 280, color: baseColor),
            const SizedBox(height: 24),
            Container(height: 18, width: double.infinity, color: baseColor),
            const SizedBox(height: 10),
            Container(height: 18, width: double.infinity, color: baseColor),
            const SizedBox(height: 10),
            Container(height: 18, width: 200, color: baseColor),
          ],
        ),
      ),
    );
  }
}
