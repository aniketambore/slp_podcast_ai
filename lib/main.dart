import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:slp_podcast_ai/home_screen.dart';
import 'package:slp_podcast_ai/responsive_layout.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlexThemeData.dark(
        scheme: FlexScheme.blue,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 20,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          blendTextTheme: true,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          defaultRadius: 24.0,
          thinBorderWidth: 2.0,
          thickBorderWidth: 4.0,
          toggleButtonsSchemeColor: SchemeColor.primary,
          toggleButtonsUnselectedSchemeColor: SchemeColor.outline,
          switchSchemeColor: SchemeColor.primary,
          checkboxSchemeColor: SchemeColor.primary,
          radioSchemeColor: SchemeColor.primary,
          unselectedToggleIsColored: true,
          sliderBaseSchemeColor: SchemeColor.primary,
          sliderIndicatorSchemeColor: SchemeColor.primary,
          sliderValueTinted: true,
          inputDecoratorBorderType: FlexInputBorderType.underline,
          fabSchemeColor: SchemeColor.primary,
          popupMenuRadius: 8.0,
          snackBarRadius: 24,
          snackBarElevation: 3,
          tabBarItemSchemeColor: SchemeColor.primary,
          tabBarUnselectedItemSchemeColor: SchemeColor.outline,
          tabBarIndicatorSchemeColor: SchemeColor.primary,
          tabBarIndicatorWeight: 4,
          tabBarIndicatorTopRadius: 8,
          drawerWidth: 300.0,
          drawerSelectedItemSchemeColor: SchemeColor.primary,
          drawerUnselectedItemSchemeColor: SchemeColor.outline,
          bottomSheetElevation: 3.0,
          bottomSheetModalElevation: 3.0,
          bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.outline,
          bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
          bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.outline,
          menuRadius: 8.0,
          menuPadding: EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
          menuBarRadius: 8.0,
          menuIndicatorRadius: 8.0,
          navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          navigationBarUnselectedLabelSchemeColor: SchemeColor.outline,
          navigationBarSelectedIconSchemeColor: SchemeColor.primary,
          navigationBarUnselectedIconSchemeColor: SchemeColor.outline,
          navigationBarHeight: 40.0,
          navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
          navigationRailUnselectedLabelSchemeColor: SchemeColor.outline,
          navigationRailSelectedIconSchemeColor: SchemeColor.primary,
          navigationRailUnselectedIconSchemeColor: SchemeColor.outline,
          navigationRailIndicatorSchemeColor: SchemeColor.primary,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
      ),
      home: const ResponsiveLayout(
        child: HomeScreen(),
      ),
    );
  }
}
