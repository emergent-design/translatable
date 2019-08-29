// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// TranslatableGenerator
// **************************************************************************

class _$Example extends TranslatableModule implements Example {
  _$Example(Resources resources)
      : super(
            resources, "example", {"Ok": "OK", "Replace": "Replace {0}, {1}"});

  String get Ok => values["Ok"];
  String Replace(String first, String second) =>
      TranslatableModule.Substitute(values["Replace"], [first, second]);
}
