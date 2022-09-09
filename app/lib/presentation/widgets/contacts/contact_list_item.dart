import 'package:flutter/material.dart';
import 'package:sudonym.models/contact.dart' as Model;
import 'package:sudonym/constants.dart';

class ContactListItem extends StatelessWidget {
  Model.Contact contact;

  ContactListItem({required this.contact, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/contact');
        },
        child: Container(
            padding: const EdgeInsets.all(padding),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(contact.get("name").substring(0, 1).toString()),
                ),
                const SizedBox(
                  width: padding,
                ),
                SizedBox(child: Text(contact.get("name").toString())),
              ],
            )));
  }
}
