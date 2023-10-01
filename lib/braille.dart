import 'dart:math';

import 'package:equatable/equatable.dart';

const int numberOfDots=6;
const bool enableSpecials=true;
const Map<String, String> dictionary = {
"W" : "111010" ,
" " : "000000" ,
""  : "000000" ,

"#" : "111100" ,
"^" : "100000" ,
"." : "110010" ,
"," : "000010" ,
":" : "010010" ,
";" : "000110" ,
"?" : "100110" ,
"!" : "010110" ,
"(" : "110110" ,
")" : "110110" ,
"\"": "110100" ,
"_" : "100100" ,
"@" : "011100" ,
};

const Map<String, String> dictionarySpecials = {

"and" : "101111" ,
"for" : "111111" ,
"of"  : "110111" ,
"the" : "101110" ,
"with": "111110" ,

"ch"  : "100001" ,
"gh"  : "100011" ,
"sh"  : "101001" ,
"th"  : "111001" ,
"wh"  : "111001" ,
"ed"  : "101011" ,
"er"  : "111011" ,
"ou"  : "110011" ,
"ow"  : "101010" ,
};

/// returns corresponding dots in binary notation, dot #1 weighs 1, dot #3 weighs 4, etc.
/// returns null if undefined.
int? _charToBraille(String char) {

  //if ( char.length > 1 ) throw Error();
  if ( char.length > 1 ) print ("ERR122 $char");

  int? codeToReturn;
  const List<String> dictionaryAToJ = [ "1" , "11" , "1001" , "11001" , "10001" , "1011" , "11011" , "10011" , "1010" , "11010" ];
  const List<String> codeLetters = ["ABCDEFGHIJ" , "KLMNOPQRST", "UVXYZ"];
  const int thirdDot=4, sixthDot=32;

  char=char.toLowerCase();
  if ( char.contains(RegExp(r"[^A-Z\d ]")) ) {  // allowed list
    return null;
  } else if ( char.contains(RegExp(r"\d")) ) {  // if input is a number, convert it to letter ( 1->a ; etc )
    if (char == "0") {char=10.toString();}
    char=codeLetters[0][int.parse(char)-1];
  }

  if ( codeLetters[0].contains(char) ) codeToReturn = int.parse(dictionaryAToJ[codeLetters[0].indexOf(char)], radix: 2);
  if ( codeLetters[1].contains(char) ) codeToReturn = int.parse(dictionaryAToJ[codeLetters[1].indexOf(char)], radix: 2) + thirdDot;
  if ( codeLetters[2].contains(char) ) codeToReturn = int.parse(dictionaryAToJ[codeLetters[2].indexOf(char)], radix: 2) + thirdDot + sixthDot;

  // Special cases:
  if (dictionary.containsKey(char)) { codeToReturn = int.parse(dictionary[char]!, radix: 2); }
  if ( enableSpecials && dictionarySpecials.containsKey(char)) { codeToReturn = int.parse(dictionarySpecials[char]!, radix: 2); }

  return codeToReturn;

}

BrailleAsBoolList? charToBrailleBoolList(String char) {
  List<bool> bitArray=[];
  int? number = _charToBraille(char);
  if (number == null) {
    return null;
  } else {
    for (int i = 0 ; i < pow(2,numberOfDots) ; i++) {
      bool isBitSet = (number & (1 << i)) != 0;
      bitArray.add(isBitSet);
    }
    return BrailleAsBoolList( bitArray);
  }

}

/// looks for a match for a given braille character (reverse function)
String? brailleBoolToChar ( BrailleAsBoolList input ) {

  //generate list of the 26 letters
  List<String> AToZ = List.generate(26, (index) {
    int asciiValue = 'A'.codeUnitAt(0) + index;
    return String.fromCharCode(asciiValue);
  });

  List<String> possibleResults = AToZ;
  if (enableSpecials) { possibleResults.addAll(dictionarySpecials.keys); }

  // try every possibility until a match occurs
  for ( int i=0 ; i < possibleResults.length ; i++ ) {
    if ( charToBrailleBoolList(possibleResults[i]) == input ) {
      return possibleResults[i];
    }
  }
  return null;
}

class BrailleAsBoolList extends Equatable {
  late final List<bool> value;

  BrailleAsBoolList([List<bool>? value]) {
    this.value = value ?? List.filled(numberOfDots, false);
  }

  @override
  List<Object?> get props => [value];

}

class MyTestClass {
  late final List<bool> value;

  MyTestClass([List<bool>? value]) {
    this.value = value ?? List.filled(numberOfDots, false);
  }

  @override
  bool operator ==(Object other) {
    bool isMyListEqual(List<Object?> a, List<Object?> b){
      if (a.length != b.length) return false;
      for (int i=0 ; i<a.length ; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    return identical(this, other) ||
    other is MyTestClass &&
    runtimeType == other.runtimeType &&
    isMyListEqual(value,other.value);
  }

  @override
  int get hashCode {
    return Object.hash(value[0],value[1],value[2],value[3],value[4],value[5]);
  }

}