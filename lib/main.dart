/// Flutter Braille Typing Game
/// Original Author: ADHSoft (github.com/adhsoft) (adhsoft0@gmail.com)
/// License GNU GPL v3

import 'package:flutter/material.dart';
import 'package:flutter_braille_typing/views/main_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_braille_typing/models/models.dart';

void main() {
  runApp(const MyAppProviders());
}

const bool demo=false;

class MyAppProviders extends StatelessWidget {
  const MyAppProviders({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<InputState>(create: (context) => InputState()),
        ChangeNotifierProvider<GameState>(create: (context) => GameState()),
        ChangeNotifierProvider<AppOptionsState>(create: (context) => AppOptionsState()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Braille Typing Game",
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xffdddddd)
      ),
      darkTheme: ThemeData.dark(),
      themeMode: Provider.of<AppOptionsState>(context).getTheme(),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

