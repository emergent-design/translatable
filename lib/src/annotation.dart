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

	const Translatable(this.module, { this.format = KeyFormat.Kebab });
}

class Translate
{
	final String source;

	const Translate(this.source);
}
