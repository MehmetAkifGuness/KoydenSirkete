import 'package:flutter/material.dart';

import '../../core/constants/app_features.dart';
import '../../core/widgets/feature_placeholder_page.dart';

abstract final class AppRouter {
  static Widget placeholder(AppFeature feature) => FeaturePlaceholderPage(feature: feature);

  static Route<void> placeholderRoute(AppFeature feature) {
    return MaterialPageRoute<void>(builder: (_) => placeholder(feature));
  }
}
