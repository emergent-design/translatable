// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// TranslatableGenerator
// **************************************************************************

class _$Example extends TranslatableModule with Example implements Example {
  _$Example(Resources resources)
      : super(resources, "example", {
          "ok": "OK",
          "multiple-name": "Multiple string name",
          "myKey": "Override key",
          "replace": "Replace \"{0}\", {1}",
          "a": "A",
          "b": "B"
        });

  String get Ok => values["ok"] ?? "";
  String get MultipleName => values["multiple-name"] ?? "";
  String get OverrideKey => values["myKey"] ?? "";
  String Replace(String first, String second) =>
      TranslatableModule.Substitute(values["replace"] ?? "", [first, second]);
  String Letters(String key) => values[key] ?? "";
}
