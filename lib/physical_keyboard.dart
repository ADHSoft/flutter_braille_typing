import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_braille_typing/braille.dart';
import 'package:flutter_braille_typing/models.dart';

class KeyboardDefs {
  static const List keys = [ LogicalKeyboardKey.keyD , LogicalKeyboardKey.keyS , LogicalKeyboardKey.keyA ,
  LogicalKeyboardKey.keyJ , LogicalKeyboardKey.keyK , LogicalKeyboardKey.keyL ];
  static const List letters = ["D","S","A","J","K","L"];
  static const int totalKeys = numberOfDots;
}

/// button that also acts as the focus node for keyboard input
class KeyboardFocus extends StatefulWidget {
  const KeyboardFocus({super.key});

  @override
  State<KeyboardFocus> createState() => _KeyboardFocusState();
}

class _KeyboardFocusState extends State<KeyboardFocus> {

  KeyEventResult _handleKeyEvent(RawKeyEvent event) {

    if ( event is RawKeyDownEvent ) {
    }
    if ( event is RawKeyUpEvent ) {
      return KeyEventResult.handled;
    }
    if ( KeyboardDefs.keys.contains(event.logicalKey) ) {
      Provider.of<InputState>(context,listen: false).changeDot(context,KeyboardDefs.keys.indexOf(event.logicalKey));
    } else {
      if ( event.logicalKey == LogicalKeyboardKey.space ) {
        submitButtonPress(context);
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    FocusNode focusNode = Provider.of<InputState>(context, listen: false).focusNode;
    return Container(
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: textTheme.headlineMedium!,
        child: Stack(
          alignment: Alignment.center,
          children: [
            RawKeyboardListener(
              focusNode: focusNode,
              onKey: _handleKeyEvent,
              child: Container(),
            ),
            IconButton(

              onPressed: () {
                keyboardButtonPressed(context);
              }, icon: Icon(Icons.keyboard) ,tooltip: "Use keyboard / take kbd. focus"
            ),
          ],
        ),
      ),
    );
  }
}

keyboardButtonPressed(BuildContext context){
  FocusScope.of(context).requestFocus(Provider.of<InputState>(context, listen: false).focusNode);
  Provider.of<AppState>(context, listen: false).keyboardButtonPressed();
}
