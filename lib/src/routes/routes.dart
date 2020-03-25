import 'package:covid19_cuba/src/features/info/screens/info_screen.dart';
import 'package:flutter/material.dart';

import 'package:covid19_cuba/src/features/dashboard/screens/dashboard_screen.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {
  return {
    'dashboard': (BuildContext context) => DashBoardScreen(),
    'info': (BuildContext context) => InfoScreen(),
  };
}
