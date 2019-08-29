import 'dart:async';
import 'package:translatable/translatable.dart';
part 'example.g.dart';

@Translatable("example")
abstract class Example
{
	factory Example(Resources resources) => _$Example(resources);

	@Translate('OK')
	String get Ok;

	// @Translate('Bad')
	// int get Bad;

	// @Translate('Test')
	// String test;

	// @Translate('NonAbstract')
	// String get NonAbstract => "Hi";

	@Translate('Replace {0}, {1}')
	String Replace(String first, String second);

	// @Translate('Bad replace {0}')
	// int BadReplace(String something);

	// @Translate('Bad abstract {0}')
	// String BadAbstract(String value) => "result";

	// @Translate('Bad parameter {0}')
	// String BadParameter(int value);

	// @Translate('No parameters')
	// String NoParameters();

	// String get NotTranslated => "hi";
}

class ExampleResources extends Resources
{
	@override Future<Map<String, String>> GetModuleEntries(String module, String language) async
	{
		return {};
	}

	@override void MissingOrphanedError(String module)
	{
		print('Missing or orphaned resources for module "$module"');
	}
}

void main(List<String> args) async
{
	var resources	= ExampleResources();
	var example		= Example(resources);

	await resources.Initialise();

	print(example.Replace("a", "b"));
	print(example.Ok);
}