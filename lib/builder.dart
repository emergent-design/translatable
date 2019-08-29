library translatable.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:translatable/src/generator.dart';

Builder translatableBuilder(BuilderOptions options) => SharedPartBuilder([ TranslatableGenerator() ], 'translatable');
