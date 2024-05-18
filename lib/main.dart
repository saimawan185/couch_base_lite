import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller/couch_db.dart';
import 'screens/contacts_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CouchDbController(),
        )
      ],
      child: MaterialApp(
        title: 'Contacts App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ContactsScreen(),
      ),
    );
  }
}
