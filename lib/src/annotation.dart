// Indicates how to rename a field/method to use as a key in the translation map
enum KeyFormat
{
	None,	// Name is unchanged
	Kebab	// Name is converted to 'kebab-case'
}

class Translatable
{
	final String module;
	final KeyFormat format;

	// If true then the translatable class is used as a mixin as well as an interface which means 
	// that any non-abstract members will be included
	final bool withMixin;		

	const Translatable(this.module, { this.format = KeyFormat.Kebab, this.withMixin = false });
}

class Translate
{
	final String source;
	final String key;

	const Translate(this.source, { this.key = '' });
}

class Lookup
{
	final Map<String, String> table;

	const Lookup(this.table);
}