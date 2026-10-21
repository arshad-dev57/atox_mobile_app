import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ad_service.dart';

/// Notifies [AdService] on Navigator push / pop / replace so interstitials
/// can respect the screen-change frequency cap.
class AdRouteObserver extends NavigatorObserver {
  void _notify() {
    if (!Get.isRegistered<AdService>()) return;
    try {
      AdService.to.onScreenChanged();
    } catch (e) {
      debugPrint('[AdRouteObserver] $e');
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Skip the very first route (app home) — only count subsequent navigations.
    if (previousRoute != null) _notify();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _notify();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _notify();
  }
}
