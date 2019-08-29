import 'resources.dart';


class TranslatableModule
{
	static final _matcher = new RegExp(r'{(\d+)}');

	final String name;
	final Map<String, String> values;
	Map<String, String> originals = {};	// Can be used by a language configuration component to detect changes


	bool missing	= false;
	bool orphaned	= false;

	TranslatableModule(Resources resources, this.name, this.values)
	{
		resources.Register(this);
	}

	TranslatableModule.base(this.name, this.values);


	static String Substitute(String text, List<String> values)
	{
		return text.replaceAllMapped(_matcher, (m) => values[int.parse(m[1])]);
	}
}