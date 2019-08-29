import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';


void IsAbstract(ExecutableElement e)
{
	if (!e.isAbstract)
	{
		throw InvalidGenerationSourceError(
			'Translate must be used on an abstract getter or method.',
			todo: 'Remove the Translate annotation or convert to an abstract getter/method',
			element: e
		);
	}
}

// Deprecate this when type.isDartCoreString becomes available (analyzer 0.36.x)
bool _IsString(DartType type) => type.element != null && type.element.library.isDartCore && type.element.name == "String";

void ReturnsString(DartType type, Element e)
{
	// if (!type.isDartCoreString)
	if (!_IsString(type))
	{
		throw InvalidGenerationSourceError(
			'Translate must be used on a getter or method returning a String.',
			todo: 'Remove the Translate annotation or modify the getter/method to return a String',
			element: e
		);
	}
}


void HasStringParameters(MethodElement e)
{
	// if (e.parameters.any((p) => !p.type.isDartCoreString))
	if (e.parameters.any((p) => !_IsString(p.type)))
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