import 'dart:developer';
import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:couch_base_lite/utils/empty_space.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/contact_model.dart';
import '../utils/app_toast.dart';
import '../utils/utils.dart';

class CouchDbController extends ChangeNotifier {
  late Database database;
  late Collection collection;
  List<Result> contactsList = [];
  String countryFlag = 'PK';
  String countryCode = '92';

  CouchDbController() {
    initializeCouchDb();
  }

  initializeCouchDb() async {
    await TracingDelegate.install(DevToolsTracing());
    await CouchbaseLiteFlutter.init();

    database = await Database.openAsync('contacts-db');
    collection = await database.createCollection('contacts');
    await collection.createIndex(
      'createdAt',
      ValueIndex([
        ValueIndexItem.property('createdAt'),
      ]),
    );
    getContactsList();
  }

  getContactsList() {
    allContactsStream().listen((results) {
      contactsList = results;
      log("Contacts: $results");
      notifyListeners();
    });
  }

  Future createContact({required ContactModel contact}) async {
    try {
      final doc = MutableDocument({
        'createdAt': DateTime.now(),
        'name': contact.name,
        'countryCode': contact.countryCode,
        'countryFlag': contact.countryFlag,
        'phone': contact.phone,
      });
      await collection.saveDocument(doc);
    } catch (e) {
      AppToast.showToast(e.toString());
    }
  }

  Future updateContact(
      {required ContactModel contact, required String docId}) async {
    try {
      final doc = MutableDocument.withId(docId, {
        'createdAt': DateTime.now(),
        'name': contact.name,
        'countryCode': contact.countryCode,
        'countryFlag': contact.countryFlag,
        'phone': contact.phone,
      });
      await collection.saveDocument(doc);
    } catch (e) {
      AppToast.showToast(e.toString());
    }
  }

  dialogBox(
      {required BuildContext context,
      ContactModel? contactModel,
      String? docId,
      bool? edit}) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    if (contactModel != null) {
      nameController.text = contactModel.name.toString();
      phoneController.text = contactModel.phone.toString();
      countryFlag = contactModel.countryFlag.toString();
      countryCode = contactModel.countryCode..toString();
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.name,
                controller: nameController,
                decoration: const InputDecoration(
                    hintText: 'Name', border: OutlineInputBorder()),
              ),
              15.height,
              TextField(
                keyboardType: const TextInputType.numberWithOptions(),
                controller: phoneController,
                decoration: InputDecoration(
                    prefixIcon: Consumer<CouchDbController>(
                      builder: (context, value, child) {
                        return SizedBox(
                          width: value.countryCode.length >= 2 ? 90 : 70,
                          child: InkWell(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                onSelect: (value) {
                                  countryFlag = value.countryCode;
                                  countryCode = value.phoneCode;
                                  notifyListeners();
                                },
                              );
                            },
                            child: Row(
                              children: [
                                10.width,
                                Text(Utils.generateFlagEmojiUnicode(
                                    value.countryFlag)),
                                5.width,
                                Text(countryCode),
                                const Icon(Icons.keyboard_arrow_down_rounded),
                                3.width,
                                Container(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    hintText: 'Phone',
                    border: const OutlineInputBorder()),
              ),
              25.height,
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  )),
                  15.width,
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      if (edit == true) {
                        updateContact(
                            contact: ContactModel(
                              name: nameController.text.trim(),
                              countryCode: countryCode,
                              countryFlag: countryFlag,
                              phone: phoneController.text.trim(),
                            ),
                            docId: docId!);
                      } else {
                        createContact(
                            contact: ContactModel(
                          name: nameController.text.trim(),
                          countryCode: countryCode,
                          countryFlag: countryFlag,
                          phone: phoneController.text..trim(),
                        ));
                      }

                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  )),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteContact(String documentId) async {
    final document = await collection.document(documentId);
    if (document != null) {
      await collection.deleteDocument(document);
    }
  }

  Stream<List<Result>> allContactsStream() {
    final query = const QueryBuilder()
        .select(
          SelectResult.expression(Meta.id),
          SelectResult.property('createdAt'),
          SelectResult.property('name'),
          SelectResult.property('countryCode'),
          SelectResult.property('countryFlag'),
          SelectResult.property('phone'),
        )
        .from(DataSource.collection(collection))
        .orderBy(Ordering.property('createdAt'));

    return query
        .changes()
        .asyncMap((change) => change.results.asStream().toList());
  }
}
