import 'package:widgetbook/widgetbook.dart';

import 'pots.dart';
import 'settings.dart';
import 'transactions.dart';

WidgetbookCategory pages = WidgetbookCategory(
  name: 'Pages',
  widgets: [transactions, pots, settings],
);

// class PageWrapper extends StatefulWidget {
//   final Widget child;
//   const PageWrapper({super.key, required this.child});

//   @override
//   State<StatefulWidget> createState() => PageWrapperState();
// }

// class PageWrapperState extends State<PageWrapper> {
//   @override
//   void initState() {
//     getIt<AuthCubit>().loginWithGoogle();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Sudonym',
//         theme: getTheme(),
//         localizationsDelegates: const [
//           AppLocalizations.delegate,
//           GlobalMaterialLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//         ],
//         darkTheme: getTheme(light: false),
//         home: AuthGate(child: widget.child));
//   }
// }
