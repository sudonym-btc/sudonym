import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/data/repository/contact.repository.dart';
import 'package:sudonym/logic/bloc/list/list.cubit.dart';
import 'package:sudonym/presentation/widgets/list/list.dart';

import '../../../injection.dart';
import 'contact_list_item.dart';

class ContactList extends StatelessWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
      Text(
        "Contacts",
        style: Theme.of(context).textTheme.headline4,
      ),
      const SizedBox(
        height: padding,
      ),
      Expanded(
          child: List(
        builder: (el) {
          return ContactListItem(contact: el);
        },
        list: ListCubit(getIt<ContactRepository>()),
        emptyText: 'No contacts found',
      ))
    ]);
  }
}
