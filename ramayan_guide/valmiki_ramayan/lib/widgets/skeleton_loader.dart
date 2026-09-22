import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../services/context_extensions.dart';


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
        padding: EdgeInsets.symmetric(vertical: context.responsiveSize(8.0)),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            height: context.responsiveSize(120.0),
            margin: EdgeInsets.symmetric(
              horizontal: context.responsiveSize(16.0),
              vertical: context.responsiveSize(6.0),
            ),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(context.responsiveSize(16.0)),
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
        padding: EdgeInsets.all(context.responsiveSize(24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: context.responsiveSize(32),
              width: context.responsiveSize(220),
              color: baseColor,
            ),
            SizedBox(height: context.responsiveSize(16)),
            Container(
              height: context.responsiveSize(1),
              width: double.infinity,
              color: baseColor,
            ),
            SizedBox(height: context.responsiveSize(24)),
            Container(
              height: context.responsiveSize(18),
              width: double.infinity,
              color: baseColor,
            ),
            SizedBox(height: context.responsiveSize(10)),
            Container(
              height: context.responsiveSize(18),
              width: double.infinity,
              color: baseColor,
            ),
            SizedBox(height: context.responsiveSize(10)),
            Container(
              height: context.responsiveSize(18),
              width: context.responsiveSize(280),
              color: baseColor,
            ),
            SizedBox(height: context.responsiveSize(24)),
            Container(
              height: context.responsiveSize(18),
              width: double.infinity,
              color: baseColor,
            ),
            SizedBox(height: context.responsiveSize(10)),
            Container(
              height: context.responsiveSize(18),
              width: double.infinity,
              color: baseColor,
            ),
            SizedBox(height: context.responsiveSize(10)),
            Container(
              height: context.responsiveSize(18),
              width: context.responsiveSize(200),
              color: baseColor,
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonStatusGrid extends StatelessWidget {
  final int itemCount;

  const SkeletonStatusGrid({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlightColor = isDark
        ? AppColors.shimmerHighlightDark
        : AppColors.shimmerHighlightLight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(20),
          vertical: context.responsiveSize(16),
        ),
        itemCount: itemCount,
        separatorBuilder: (_, i) => SizedBox(height: context.responsiveSize(20)),
        itemBuilder: (context, index) {
          return AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(context.responsiveSize(20)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SkeletonStatusRow extends StatelessWidget {
  const SkeletonStatusRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlightColor = isDark
        ? AppColors.shimmerHighlightDark
        : AppColors.shimmerHighlightLight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SizedBox(
        height: context.responsiveSize(200),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
          itemCount: 4,
          separatorBuilder: (_, i) => SizedBox(width: context.responsiveSize(12)),
          itemBuilder: (_, j) => AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(context.responsiveSize(14)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
