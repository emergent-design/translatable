import 'dart:async';
import 'package:translatable/src/module.dart';

abstract class Resources
{
	List<TranslatableModule> _modules = [];

	void Register(TranslatableModule module)
	{
		this._modules.add(module);
	}

	// Future<List<Language>> Languages();
	Future Initialise({ void onError(String) }) async
	{
		// Retrieve values for current language and check if any expected values
		// are missing or unexpected values found
		for (var m in this._modules)
		{
			await LoadModule(m, null);

			if ((m.missing || m.orphaned) && onError != null)
			{
				onError(m.name);
			}
		}
	}

	// Implement this to retrieve a map of strings for a given module based on how data
	// is stored in your server-side application. If language is `null` then return
	// the values for the appropriate language based on the browser request header. If
	// language is a known code then return that language.
	Future<Map<String, String>> GetModuleEntries(String module, String language);


	// Update a module with translations for a specific language or based on the browser
	// request header if language is `null`.
	Future<TranslatableModule> LoadModule(TranslatableModule module, String language) async
	{
		var entries = await GetModuleEntries(module.name, language);

		if (entries != null)
		{
			module.orphaned = entries.keys.any((k) => !module.values.containsKey(k));
			module.missing	= false;

			for (var k in module.values.keys)
			{
				if (entries.containsKey(k)) module.values[k]	= entries[k];
				else						module.missing		= true;
			}
		}

		return module;
	}

	// Load duplicates of all modules for a specific language. This can be used by a language
	// configuration component to provide an interface for modifying the language strings.
	Future<List<TranslatableModule>> Load(String language) async
	{
		List<TranslatableModule> result = [];

		for (var m in this._modules)
		{
			var module = await this.LoadModule(
				TranslatableModule.base(m.name, Map.from(m.values)),
				language
			);

			module.originals = Map.from(module.values);
			result.add(module);
		}

		return result;
	}


}
