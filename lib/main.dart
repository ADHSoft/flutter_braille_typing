/// Flutter Braille Typing Game
/// By ADHSoft (github.com/adhsoft) (adhsoft0@gmail.com)
/// All rights reserved

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_braille_typing/physical_keyboard.dart';
import 'package:flutter_braille_typing/models.dart';

import 'braille.dart';
import 'braille_ui.dart';

void main() {
  runApp(const MyAppProviders());
}

const bool demo=false;
const String appTitle=demo ? "Braille Learning" : "Flutter Braille Typing Game";

class MyAppProviders extends StatelessWidget {
  const MyAppProviders({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<InputState>(create: (context) => InputState()),
        ChangeNotifierProvider<AppState>(create: (context) => AppState()),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xffdddddd)
      ),
      darkTheme: ThemeData.dark(),
      themeMode: Provider.of<AppState>(context).getTheme(),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override

  Widget build(BuildContext context) {
    String? targetLabel, targetLetter;

    targetLetter = Provider.of<AppState>(context).targetCharacter;
    String inputLetter = brailleBoolToChar(Provider.of<InputState>(context).keys) ?? " ";
    targetLabel = "Objective : \"${targetLetter.toUpperCase()}\"";
    String inputLabel="Input character ( ${inputLetter.toUpperCase()} ) :";

    String title=appTitle;
    int goal=Provider.of<AppState>(context).goalPos;
    int pos=Provider.of<AppState>(context).currentPos;
    int score=Provider.of<AppState>(context).score;

    switch (Provider.of<AppState>(context).state) {
      case GameState.running:
        title= "($pos/$goal) - score: $score";
        break;
      case GameState.won:
        title="You won! Score: $score";
        break;
      case GameState.initial:
      case GameState.pause:
        break;
    }

    IconData brightness=Icons.settings_brightness;
    if (Provider.of<AppState>(context).darkTheme == true) brightness=Icons.mode_night;
    if (Provider.of<AppState>(context).darkTheme == false) brightness=Icons.light_mode;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          KeyboardFocus(),
          /*IconButton(
            onPressed: () {

            }, icon: Icon(Icons.screen_rotation) ,tooltip: "Vertical/Horizontal layout"
          ),*/
          IconButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).changeTheme();
            }, icon: Icon(brightness) ,tooltip: "Theme"
          ),
        ],
      ),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text("Target text:"),
                 TextField(
                    minLines: 1,
                    maxLines: 4,
                    onChanged: (_) {
                      Provider.of<AppState>(context, listen: false).resetGame();
                    },
                    onTap:  () {
                      Provider.of<AppState>(context, listen: false).pause();
                    },
                    controller: Provider.of<AppState>(context, listen: false).controller,
                  ),
               ]),
          ),
          Flexible(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Spacer(flex: 1),
                Flexible(flex: 10, child: InputBrailleCharacter(label: inputLabel)),
                Spacer(flex: 1),
                Flexible(flex: 4, child: TargetBrailleCharacter(label: targetLabel)),
                Spacer(flex: 1),
              ]
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(child: Text(!demo ? "© ${DateTime.now().year} ADHSoft" : "© ${DateTime.now().year}", style: TextStyle(color: Theme.of(context).disabledColor)),
              onTap: () {
                ShowLicensePage(context);
              },
            ),
          ),
          Container( height: MediaQuery.of(context).size.height > 500 ? 15 : 0,)
        ],
      ),
    );
  }
}

class InputBrailleCharacter extends StatelessWidget {
  InputBrailleCharacter({super.key, required this.label});

  String label;

  @override
  Widget build(BuildContext context) {
    List<BrailleDotData> dotData=[];
    for (int i=0;i<KeyboardDefs.totalKeys ;i++){
      dotData.add(
        BrailleDotData(
          state: Provider.of<InputState>(context).keys.value[i],
          letter: Provider.of<AppState>(context).showKeyboardLetters ? KeyboardDefs.letters[i] : " ",
          id: i ,
        )
      );
    }
    BrailleAsBoolList input = Provider.of<InputState>(context, listen: false).keys;
    bool rightAnswer = Provider.of<AppState>(context).isRightAnswer(input);
    return Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Center(child:Text(label)),fit: FlexFit.tight,),
        Flexible(
          flex: 5,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: BrailleCharacter(
              dots: dotData,
              onDotPress: (dotId) {
                Provider.of<InputState>(context, listen: false).changeDot(context,dotId );
              }
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Center(child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: rightAnswer ? MaterialStateProperty.all<Color>(Color(0xff00a010)) : null,
            ),
            onPressed: () {
              submitButtonPress(context);
            },
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text( (rightAnswer ? "✅ Next" : "Clear") + (Provider.of<AppState>(context).showKeyboardLetters ? " [Spacebar]" : "") ,
              style: rightAnswer ? TextStyle( fontWeight: FontWeight.bold ) : const TextStyle(),textAlign:TextAlign.center
              )
            ),
          ))
        ),
      ]
    );
  }
}

class TargetBrailleCharacter extends StatelessWidget {
  const TargetBrailleCharacter({super.key, required this.label});

  final String label;
  @override
  Widget build(BuildContext context) {
    bool hide=!Provider.of<AppState>(context).answerVisible;
    List<BrailleDotData> dotData=[];
    String? target = Provider.of<AppState>(context).targetCharacter;
    for (int i=0;i<KeyboardDefs.totalKeys ;i++){
      dotData.add(
        BrailleDotData(
          state: hide ? false : (charToBrailleBoolList(target)?.value[i] ?? false ),
          letter: hide ? "?" : "", id: i
        )
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Spacer(flex: 22,),
        Text(label,),
        Spacer(),
        Expanded(flex: 12,
          child: BrailleCharacter(dots: dotData),
        ),
        Spacer(),
        TextButton(
          child: Text(hide ? "Show answer" : "Hide answer",textAlign:TextAlign.center ),
          onPressed: () {
            Provider.of<AppState>(context, listen: false).setAnswerVisible();
          },
        ),
      ]
    );
  }
}

ShowLicensePage(BuildContext context) async {
  await showDialog(context: context, builder: (context) => LicensePage(
    applicationName: appTitle,
    applicationLegalese: "© ${DateTime.now().year} ADHSoft\nAuthor: Alejandro Herme\n"
    "Uses software listed below.",
    applicationVersion: "1.0.0",
  ));
}
