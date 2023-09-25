import 'dart:math';

const int numberOfDots=6;

/// returns corresponding dots in binary notation, dot #1 weighs 1, dot #3 weighs 4, etc.
/// returns null if undefined.
int? _charToBraille(String char) {

  assert ( char.length < 2 );

  int? codeToReturn;

  const List<String> dotCodes = [ "1" , "11" , "1001" , "11001" , "10001" , "1011" , "11011" , "10011" , "1010" , "11010" ];
  const List<String> codeLetters = ["abcdefghij" , "klmnopqrst", "uvxyz"];
  const int thirdDot=4;
  const int sixthDot=32;

  char=char.toLowerCase();
  if ( char.contains(RegExp(r"[^a-z\d ]")) ) {  // allowed list
    return null;
  } else if ( char.contains(RegExp(r"\d")) ) {  // if input is a number, convert it to letter ( 1->a ; etc )
    if (char == "0") {char= "11";}
    char=codeLetters[0][int.parse(char)-1];
  }

  if ( codeLetters[0].contains(char) ) codeToReturn = int.parse(dotCodes[codeLetters[0].indexOf(char)], radix: 2);
  if ( codeLetters[1].contains(char) ) codeToReturn = int.parse(dotCodes[codeLetters[1].indexOf(char)], radix: 2) + thirdDot;
  if ( codeLetters[2].contains(char) ) codeToReturn = int.parse(dotCodes[codeLetters[2].indexOf(char)], radix: 2) + thirdDot + sixthDot;

  // Special cases:
  if (char == "w") { codeToReturn = int.parse("111010", radix: 2); }
  if (char == " ") { codeToReturn = 0 ; }
  if (char == "") { codeToReturn = 0 ; }

  return codeToReturn;

}

BrailleAsBoolList? charToBrailleBoolList(String char, {returnSpaceIfNull = false}) {
  List<bool> bitArray=[];
  int? number = _charToBraille(char);
  if (number == null) {
    return (returnSpaceIfNull ? BrailleAsBoolList() : null);
  } else {
    for (int i = 0 ; i < pow(2,numberOfDots) ; i++) {
      bool isBitSet = (number & (1 << i)) != 0;
      bitArray.add(isBitSet);
    }
    return BrailleAsBoolList(value: bitArray);
  }

}

/// does a reverse search to find a match for a given braille character
String? brailleBoolToChar ( BrailleAsBoolList input ) {

  //generate list of the 26 letters
  List<String> possibleResults = List.generate(26, (index) {
    int asciiValue = 'a'.codeUnitAt(0) + index;
    return String.fromCharCode(asciiValue);
  });

  // try every possibility until a match occurs
  for ( int i=0 ; i < possibleResults.length ; i++ ) {
    if ( charToBrailleBoolList(possibleResults[i]) == input ) {
      return possibleResults[i];
    }
  }
  return null;
}

class BrailleAsBoolList {
  late List<bool> value;

  BrailleAsBoolList({List<bool>? value }) {
    this.value = value ?? List.filled(numberOfDots, false);
  }

  @override
  bool operator ==(Object other) {
    if (other is BrailleAsBoolList) {
      bool different=false;
      for (int i=0;i<numberOfDots;i++) {
        if (other.value[i] != value[i]) {
          different = true;
        }
      }

      return !different;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => value.hashCode;

}


