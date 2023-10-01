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
class KeyboardFocus extends StatelessWidget {
  const KeyboardFocus({super.key});

  _handleKeyEvent(BuildContext context, RawKeyEvent event) {

    /*if ( event is RawKeyDownEvent ) {
    }*/
    if ( event is !RawKeyDownEvent ) {
      return;
    }
    if ( KeyboardDefs.keys.contains(event.logicalKey) ) {
      Provider.of<InputState>(context,listen: false).changeDot(context,KeyboardDefs.keys.indexOf(event.logicalKey));
    } else {
      if ( event.logicalKey == LogicalKeyboardKey.space ) {
        submitButtonPress(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode = Provider.of<InputState>(context, listen: false).focusNode;
    return Stack(
      alignment: Alignment.center,
      children: [
        RawKeyboardListener(
          focusNode: focusNode,
          onKey: (event) {
            _handleKeyEvent(context, event);
          },
          child: Container(),
        ),
        IconButton(
          onPressed: () {
            keyboardButtonPressed(context);
          }, icon: Icon(Icons.keyboard) ,tooltip: "Use physical keyboard"
        ),
      ],
    );
  }
}

keyboardButtonPressed(BuildContext context){
  FocusScope.of(context).requestFocus(Provider.of<InputState>(context, listen: false).focusNode);
  Provider.of<AppState>(context, listen: false).keyboardButtonPressed();
}
