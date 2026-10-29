import 'package:bookish/app/app.bottomsheets.dart';
import 'package:bookish/app/app.dialogs.dart';
import 'package:bookish/app/app.locator.dart';
import 'package:bookish/app/app.router.dart';
import 'package:bookish/ui/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(const Bookish());
}

class Bookish extends StatelessWidget {
  const Bookish({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookish',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}
