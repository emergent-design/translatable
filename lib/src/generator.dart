import 'dart:async';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:translatable/src/annotation.dart';


final _translateChecker = const TypeChecker.fromRuntime(Translate);

class TranslatableGenerator extends GeneratorForAnnotation<Translatable>
{
	const TranslatableGenerator();


	void CheckGetter(FieldElement e)
	{
		if (e.getter == null)
		{
			throw InvalidGenerationSourceError(
				'Generator cannot be applied to simple fields.',
				todo: 'Remove the Translate annotation or convert to an abstract getter.',
				element: e
			);
		}
	}

	void CheckAbstract(bool valid, Element e)
	{
		if (!valid)
		{
			throw InvalidGenerationSourceError(
				'Translate must be used on an abstract getter or method.',
				todo: 'Remove the Translate annotation or convert to an abstract getter/method',
				element: e
			);
		}
	}

	void CheckString(DartType type, Element e)
	{
		if (!type.isDartCoreString)
		{
			throw InvalidGenerationSourceError(
				'Translate must be used on a getter or method returning a String.',
				todo: 'Remove the Translate annotation or modify the getter/method to return a String',
				element: e
			);
		}
	}

	void CheckParameters(MethodElement e)
	{
		if (e.parameters.any((p) => !p.type.isDartCoreString))
		{
			throw InvalidGenerationSourceError(
				'All parameters for a method annotated with Translate must be of type String.',
				todo: 'Remove the Translate annotation or change all parameters to String',
				element: e
			);
		}
		if (e.parameters.isEmpty)
		{
			throw InvalidGenerationSourceError(
				'A method annotated with Translate must have at least one parameter, consider using a getter instead.',
				todo: 'Remove the Translate annotation or convert to a getter',
				element: e
			);
		}
	}


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
		final fields		= classElement.fields.where((f) => _translateChecker.hasAnnotationOfExact(f.getter ?? f));
		final methods		= classElement.methods.where((m) => _translateChecker.hasAnnotationOfExact(m));

		var buffer = StringBuffer();
		List<String> values = [];

		for (var f in fields)
		{
			this.CheckGetter(f);
			this.CheckAbstract(f.getter.isAbstract, f);
			this.CheckString(f.type, f);

			values.add('"${f.name}": "${_translateChecker.firstAnnotationOfExact(f.getter).getField("source").toStringValue()}"');
			buffer.write('String get ${f.name} => values["${f.name}"];\n');
		}

		for (var m in methods)
		{
			this.CheckAbstract(m.isAbstract, m);
			this.CheckString(m.returnType, m);
			this.CheckParameters(m);

			final parameters	= m.parameters.map((p) => 'String ${p.name}').join(', ');
			final list			= m.parameters.map((p) => p.name).join(', ');

			values.add('"${m.name}": "${_translateChecker.firstAnnotationOfExact(m).getField("source").toStringValue()}"');
			buffer.write('String ${m.name}($parameters) => TranslatableModule.Substitute(values["${m.name}"], [ $list ]);\n');
		}

		yield '''
			class $className extends TranslatableModule implements ${classElement.name}
			{
				$className(Resources resources) : super(resources, "$name", {
					${values.join(",\n")}
				});
		''';

		yield buffer.toString();
		yield '}';
	}
}

