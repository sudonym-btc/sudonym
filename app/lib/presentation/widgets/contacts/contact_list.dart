import 'package:flutter/material.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:sudonym/injection.dart';

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
            builder: (el) =>
                CubitWrapper<ContactCubit, ContactCubitState, Contact>(
                    entity: el,
                    fetch: false,
                    builder: (context, state) =>
                        ContactListItem(contact: state.entity!)),
            list: () => ListCubit(getIt<ContactRepository>()),
            emptyText: AppLocalizations.of(context)!.noContactsFound,
          ))
        ]);
  }
}
