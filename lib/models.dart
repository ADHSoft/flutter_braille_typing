import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_braille_typing/braille.dart';
import 'package:provider/provider.dart';

enum GameState {
  running,
  won,
  pause,
  initial
}

class AppState extends ChangeNotifier {
  late TextEditingController controller;
  late String targetCharacter;
  late GameState state;
  late int goalPos, currentPos, score;
  late bool showKeyboardLetters, verticalLayout, answerVisible, answerShown;
  bool? darkTheme;

  AppState() {
    controller = TextEditingController(text: "Your objective is to write the text of this box, letter by letter, in braille, by turning on the right dots.");
    reset();
  }

  reset() {
    answerVisible=true;
    resetGame();
    verticalLayout=false;
    showKeyboardLetters=false;
    notifyListeners();
  }
  resetGame() {
    answerShown=answerVisible;
    score=0;
    state  = GameState.initial;
    targetCharacter = " ";
    goalPos=controller.value.text.length;
    currentPos = 0;
    _refreshTarget();
  }

  changeTheme() {
    darkTheme ??= true;
    darkTheme = ! darkTheme!;
    notifyListeners();
  }

  ThemeMode getTheme() {
    if (darkTheme==null) return ThemeMode.system;
    return darkTheme! ? ThemeMode.dark : ThemeMode.light;
  }

  _refreshTarget(){
    if (goalPos==currentPos) {
      state=GameState.won;
      currentPos = 0;
    } else if (goalPos < currentPos) {
      currentPos = 0;
    } else {
      if (goalPos == 0) { // no input text
        resetGame();
        controller.text="Example";
      }
      targetCharacter=controller.value.text[currentPos];
    }
  }

  keyboardButtonPressed(){
    showKeyboardLetters=!showKeyboardLetters;

    notifyListeners();
  }
  resume(){
    state=GameState.running;
    _refreshTarget();
    notifyListeners();
  }
  pause(){
    state=GameState.pause;
    notifyListeners();
  }
  bool isRightAnswer(BrailleAsBoolList input){
    return (input == (charToBrailleBoolList(targetCharacter) ?? BrailleAsBoolList()) && (state != GameState.won));
  }
  bool submitInput(BrailleAsBoolList input){
    const bool skipSpaces=true;
    if (state != GameState.running ) {
      return false;
    }
    _refreshTarget();
    do {
      if (isRightAnswer(input) || (targetCharacter==" " && skipSpaces) ) {
        if ( targetCharacter!=" " && input != BrailleAsBoolList() ) {
          changeScore(100);
        }
        currentPos++;
        answerShown=answerVisible;
      }
      _refreshTarget();
    } while ( targetCharacter == " " && skipSpaces && state != GameState.won);

    notifyListeners();
    return (state == GameState.won);
  }
  changeScore(int score) {
    if (!answerShown) this.score+=score;
    notifyListeners();
  }
  setAnswerVisible({bool? s}){
    s ??= !answerVisible;
    if (!answerVisible && state==GameState.running) {
      changeScore(-100);
      answerShown=true;
    }
    answerVisible=s;
    notifyListeners();
  }
}

void submitButtonPress(BuildContext context) {
  if (Provider.of<AppState>(context, listen: false).submitInput(Provider.of<InputState>(context,listen: false).keys )) {
    if (Provider.of<AppState>(context, listen: false).score > 100 ) {
      showSnackBar(context, 'Game finished. Better luck for next time.', 5);
    } else {
      showSnackBar(context, 'Congratulations!! You won.', 5);
    }
  }
  Provider.of<InputState>(context,listen: false).changeToALetter(BrailleAsBoolList());
}

void showSnackBar(BuildContext context, String message, int seconds) {
  final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: seconds),
    ),
  );
}

class InputState extends ChangeNotifier {
  late BrailleAsBoolList keys;
  late FocusNode focusNode;

  InputState() {
    reset();
  }

  @override
  void dispose() {
    focusNode.dispose(); // Focus nodes need to be disposed.
    super.dispose();
  }

  reset() {
    keys = BrailleAsBoolList();
    focusNode = FocusNode();
  }
  changeDot(BuildContext context, int index, {bool? state}) { //state == null =>  means to toggle state
    keys.value[index] = state ?? !(keys.value[index]);
    Provider.of<AppState>(context,listen: false).changeScore(-10);
    notifyListeners();
  }
  changeToALetter(BrailleAsBoolList value) {
    keys=value;
    notifyListeners();
  }
}