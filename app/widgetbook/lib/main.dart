import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sudonym/main.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:widgetbook/widgetbook.dart';

import './buttons.dart';
import './inputs.dart';
import './notifications.dart';
import './pages/pages.dart';
import './typography.dart';
import './widgets/widgets.dart';

void main() async {
  await mainSetup('mock');
  runApp(const HotreloadWidgetbook());
}

class HotreloadWidgetbook extends StatelessWidget {
  const HotreloadWidgetbook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      categories: [pages, buttons, inputs, typography, widgets, notifications],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('de'),
      ],
      themes: [
        WidgetbookTheme(
          name: 'Light',
          data: getTheme(),
        ),
        WidgetbookTheme(
          name: 'Dark',
          data: getTheme(light: false),
        ),
      ],
      frames: [WidgetbookFrame.deviceFrame()],
      devices: [
        Apple.iPhone13ProMax,
        Samsung.s21ultra,
      ],
      appInfo: AppInfo(name: 'Sudonym'),
      appBuilder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sudonym',
          theme: getTheme(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('de'),
          ],
          darkTheme: getTheme(light: false),
          home: AuthGate(child: child)),
    );
  }
}
