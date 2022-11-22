import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
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
          : Slidable(
              // Specify a key if the Slidable is dismissible.
              key: const ValueKey(0),

              // The start action pane is the one at the left or the top side.
              startActionPane: ActionPane(
                // A motion is a widget used to control how the pane animates.
                motion: const ScrollMotion(),

                // A pane can dismiss the Slidable.
                // dismissible: DismissiblePane(onDismissed: () {}),

                // All actions are defined in the children parameter.
                children: [
                  // A SlidableAction can have an icon and/or a label.
                  SlidableAction(
                    onPressed: (BuildContext context) async {
                      await getIt<ContactRepository>().delete(state.entity!.id);
                    },
                    backgroundColor: Theme.of(context).errorColor,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: (BuildContext context) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              EditContactPage(entity: state.entity!)));
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                ],
              ),

              // The child of the Slidable is what the user sees when the
              // component is not dragged.
              child: InkWell(
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
                      ))),
            ),
    );
  }
}
