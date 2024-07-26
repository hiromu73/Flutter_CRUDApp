import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingLanguagePage extends HookConsumerWidget {
  const SettingLanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectedValue = useState<String>("ja");

    return DropdownButton(
      items: const [
        DropdownMenuItem(
          value: 'ja',
          child: Text('Japanese'),
        ),
        DropdownMenuItem(
          value: 'en',
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: 'zh',
          child: Text('Chinese'),
        ),
        DropdownMenuItem(
          value: 'ko',
          child: Text('Korean'),
        ),
        DropdownMenuItem(
          value: 'de',
          child: Text('German'),
        ),
        DropdownMenuItem(
          value: 'fr',
          child: Text('French'),
        ),
        DropdownMenuItem(
          value: 'es',
          child: Text('Spanish'),
        ),
      ],
      value: isSelectedValue.value,
      onChanged: (Object? language) {
        isSelectedValue.value = language.toString();
        changeLanguage(context, isSelectedValue.value, ref);
      },
    );
  }

  void changeLanguage(
      BuildContext context, String languageCode, WidgetRef ref) async {
    MyApp myappApi = const MyApp();
    Locale newLocale = Locale(languageCode);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);

    myappApi.updateLocale(ref, newLocale);
    print('現在のlanguageCodeは、$languageCode');

    // Navigator.pop(context); // メニューを閉じる
  }
}
