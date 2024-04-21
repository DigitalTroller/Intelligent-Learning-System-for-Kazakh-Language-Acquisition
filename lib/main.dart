import 'package:flutter/material.dart';
import 'package:google_translator/google_translator.dart';
import 'home_screen.dart';

void main() {
  /// Required to make the `GoogleTranslatorInit` call before the `MaterialApp`
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  final String apiKey = "AIzaSyBuYHcK72-I3aNNDkToEytGw9oCfXxXx80";
  @override
  Widget build(BuildContext context) {
    return GoogleTranslatorInit(apiKey,
      translateFrom: Locale('kk'),
      translateTo: Locale('en'),
      // automaticDetection: , In case you don't know the user language will want to traslate,
      // cacheDuration: Duration(days: 13), The duration of the cache translation.
      builder: () => MaterialApp(
        title: 'Kazakh Dictionary',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}