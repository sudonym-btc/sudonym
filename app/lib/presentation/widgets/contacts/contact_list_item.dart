import 'package:flutter/material.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final Function()? onPressed;

  const ContactListItem({super.key, required this.contact, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<ContactCubit, ContactCubitState, Contact>(
        entity: contact,
        fetch: false,
        builder: (context, state) => state.loading
            ? Container()
            : InkWell(
                onTap: onPressed ??
                    () {
                      Navigator.of(context).pushNamed('/contact');
                    },
                child: Container(
                    padding: const EdgeInsets.all(padding),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                              state.entity!.name.substring(0, 1).toString()),
                        ),
                        const SizedBox(
                          width: padding,
                        ),
                        SizedBox(child: Text(state.entity!.name.toString())),
                      ],
                    ))));
  }
}
