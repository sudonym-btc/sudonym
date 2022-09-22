import 'package:sudonym/presentation/index.dart';
import 'package:widgetbook/widgetbook.dart';

//cd app
//flutter run  -t ./widgetbook/lib/main.dart -d macos

WidgetbookCategory notifications = WidgetbookCategory(
  name: 'Notifications',
  widgets: [
    WidgetbookComponent(
      name: 'notification',
      useCases: [
        WidgetbookUseCase(
          name: 'SentNotification',
          builder: (context) => SentNotification(
            text: 'You\'ve sent 100,000 sats!',
          ),
        ),
        WidgetbookUseCase(
          name: 'RecievedNotification',
          builder: (context) => RecievedNotification(
            text: 'You\'ve recieved 100,000sats!',
          ),
        ),
        WidgetbookUseCase(
          name: 'PaymentErrorNotification',
          builder: (context) => ErrorNotification(
            text: 'Payment Failed',
          ),
        ),
        WidgetbookUseCase(
          name: 'Paste Address',
          builder: (context) => const PasteNotification(),
        ),
      ],
    ),
  ],
);
