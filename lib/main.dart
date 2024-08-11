import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/constants/routes.dart';
import 'package:memoplace/ui/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(
    child: MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false),
  ));
}

final localeProvider = StateProvider<Locale>((ref) => const Locale('ja', ''));

class MyApp extends HookConsumerWidget {
  void updateLocale(WidgetRef ref, Locale newLocale) {
    ref.read(localeProvider.notifier).state = newLocale;
  }

  const MyApp({super.key});
  static const Color mainColor = Color(0xFFFFE0B2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    Locale? locale = ref.watch(localeProvider);
    void loadSavedLanguage() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedLanguageCode = prefs.getString('languageCode');
      print("locale");
      print(locale);
      if (savedLanguageCode != null) {
        locale = Locale(savedLanguageCode);
        return null;
      }
    }

    useEffect(() {
      loadSavedLanguage();
      updateLocale(ref, locale!);
      return null;
    }, []);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', ''),
        Locale('en', ''),
        Locale('zh', ''),
        // Locale('fr', ''),
        // Locale('de', ''),
        // Locale('ko', ''),
      ],
      title: 'MemoPlace',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        primaryColor: mainColor,
        colorScheme: ColorScheme.light(
          background: mainColor,
          primary: Colors.black,
          secondary: Colors.grey.shade200,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        primaryColor: mainColor,
        colorScheme: ColorScheme.light(
          background: mainColor,
          primary: Colors.black,
          secondary: Colors.grey.shade200,
        ),
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      locale: locale,
    );
  }
}
