import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

class ContactList extends StatelessWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Header(AppLocalizations.of(context)!.contacts),
          const SizedBox(
            height: padding,
          ),
          Expanded(
              child: ListWidget(
            builder: (el) => ContactListItem(
              contact: el!,
              onPressed: () {},
            ),
            list: () => ListCubit(getIt<ContactRepository>()),
            emptyText: AppLocalizations.of(context)!.noContactsFound,
          ))
        ]);
  }
}
