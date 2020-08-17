import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:translatable/src/annotation.dart';

import 'type_checks.dart';


final _translateChecker		= const TypeChecker.fromRuntime(Translate);
final _lookupChecker		= const TypeChecker.fromRuntime(Lookup);
final _upperCase			= RegExp('[A-Z]');


String _key(KeyFormat format, String name, String override)
{
	if (override.isNotEmpty)
	{
		// This field/method has an explicitly declared key
		// so use that instead of generating one.
		return override;
	}

	switch (format)
	{
		case KeyFormat.None:	return name;
		case KeyFormat.Kebab:	return name.replaceAllMapped(_upperCase, (m) => m.start > 0
			? '-${m.group(0).toLowerCase()}'
			: m.group(0).toLowerCase()
		);
	}

	return name;
}

// Retrieve the key from the annotation. If the
// key is empty then the default key naming method
// will be used instead.
String _keyOverride(Element e)
{
	return _translateChecker
		.firstAnnotationOfExact(e)
		.getField('key')
		.toStringValue();
}


class TranslatableGenerator extends GeneratorForAnnotation<Translatable>
{
	const TranslatableGenerator();

	@override Stream<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async*
	{
		if (element is! ClassElement)
		{
			throw InvalidGenerationSourceError(
				'Generator cannot target `${element.name}` since it must be a class',
				todo: 'Remove the Translatable annotation from `${element.name}`.',
				element: element
			);
		}

		final classElement	= element as ClassElement;
		final className		= '_\$${classElement.name}';
		final name			= annotation.read('module').stringValue;
		final withMixin		= annotation.read('withMixin').boolValue ? "with ${classElement.name}" : "";
		final fields		= classElement.fields.where((f) => _translateChecker.hasAnnotationOfExact(f.getter) || _translateChecker.hasAnnotationOfExact(f));
		final methods		= classElement.methods.where((m) => _translateChecker.hasAnnotationOfExact(m));
		final lookups		= classElement.methods.where((m) => _lookupChecker.hasAnnotationOfExact(m));
		final format		= KeyFormat.values.singleWhere(
			(v) => annotation.read('format').objectValue.getField(v.toString().split('.')[1]) != null
		);

		var buffer					= StringBuffer();
		Map<String, String> values	= {};

		for (var f in fields)
		{
			final key = _key(format, f.name, _keyOverride(f.getter));

			IsAbstract(f.getter);
			ReturnsString(f.type, f);
			DoesNotContainKey(f.getter, values, key);

			values[key] = _translateChecker
				.firstAnnotationOfExact(f.getter)
				.getField('source')
				.toStringValue()
				.replaceAll('"', '\\"');

			buffer.write('String get ${f.name} => values["${key}"];\n');
		}

		for (var m in methods)
		{
			final key = _key(format, m.name, _keyOverride(m));

			IsAbstract(m);
			ReturnsString(m.returnType, m);
			HasStringParameters(m);
			DoesNotContainKey(m, values, key);

			final parameters	= m.parameters.map((p) => 'String ${p.name}').join(', ');
			final list			= m.parameters.map((p) => p.name).join(', ');
			values[key]			= _translateChecker
				.firstAnnotationOfExact(m)
				.getField('source')
				.toStringValue()
				.replaceAll('"', '\\"');

			buffer.write('String ${m.name}($parameters) => TranslatableModule.Substitute(values["${key}"], [ $list ]);\n');
		}

		for (var l in lookups)
		{
			IsAbstract(l);
			ReturnsString(l.returnType, l);
			HasStringParameters(l, 1);

			final table	= _lookupChecker
				.firstAnnotationOfExact(l)
				.getField('table')
				.toMapValue()
				.map<String, String>((k, v) => MapEntry(
					k.toStringValue(),
					v.toStringValue().replaceAll('"', '\\"')
				));

			table.forEach((k, v) => DoesNotContainKey(l, values, k));
			values.addAll(table);
			buffer.write('String ${l.name}(String key) => values[key];\n');
		}



		yield '''
			class $className extends TranslatableModule $withMixin implements ${classElement.name}
			{
				$className(Resources resources) : super(resources, "$name", {
					${values.keys.map((k) => '"${k}": "${values[k]}"').join(',\n')}
				});
		''';

		yield buffer.toString();
		yield '}';
	}
}

