
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/couch_db.dart';
import '../model/contact_model.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        centerTitle: true,
      ),
      floatingActionButton: IconButton(
        onPressed: () {
          Provider.of<CouchDbController>(context, listen: false)
              .dialogBox(context: context);
        },
        icon: const Icon(
          Icons.add_circle_rounded,
          size: 50,
          color: Colors.blueAccent,
        ),
      ),
      body: Consumer<CouchDbController>(
        builder: (context, value, child) {
          return ListView.builder(
            itemCount: value.contactsList.length,
            itemBuilder: (context, index) {
              return ListTile(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          value.deleteContact(
                              value.contactsList[index].value('id').toString());
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        )),
                    IconButton(
                        onPressed: () {
                          final ContactModel contactModel = ContactModel(
                            name: value.contactsList[index]
                                .value('name')
                                .toString(),
                            countryCode: value.contactsList[index]
                                .value('countryCode')
                                .toString(),
                            countryFlag: value.contactsList[index]
                                .value('countryFlag')
                                .toString(),
                            phone: value.contactsList[index]
                                .value('phone')
                                .toString(),
                          );
                          value.dialogBox(
                            context: context,
                            contactModel: contactModel,
                            docId: value.contactsList[index]
                                .value('id')
                                .toString(),
                            edit: true,
                          );
                        },
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: Colors.blueAccent,
                        )),
                  ],
                ),
                title: Text(value.contactsList[index].value('name').toString()),
                subtitle: Text(
                    '+${value.contactsList[index].value('countryCode')}${value.contactsList[index].value('phone')}'),
              );
            },
          );
        },
      ),
    );
  }
}
