import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/res/app_theme.dart';
import 'package:lim_crm/res/providers.dart';
import 'package:lim_crm/screens/splash_screen/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Load the saved language
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedLocale = prefs.getString('saved_locale');

  runApp(MyApp(savedLocale: savedLocale));
}

class MyApp extends StatefulWidget {
  final String? savedLocale;

  const MyApp({super.key, this.savedLocale});

  @override
  State<MyApp> createState() => _MyAppState();

  // 🔥 Static helper to change locale from anywhere
  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('fr');

  @override
  void initState() {
    super.initState();
    if (widget.savedLocale != null) {
      _locale = Locale(widget.savedLocale!);
    }
  }

  Future<void> setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_locale', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [...providers],
      child: MaterialApp(
        title: 'MY Vapp',
        theme: AppTheme.lightTheme,
        locale: _locale,
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('fr', 'FR'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
