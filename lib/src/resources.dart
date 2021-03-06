import 'dart:async';
import 'package:translatable/src/module.dart';

abstract class Resources
{
	final _initialised				= StreamController<void>.broadcast();
	Stream<void> get initialised	=> _initialised.stream;

	List<TranslatableModule> _modules = [];


	void Register(TranslatableModule module)
	{
		this._modules.add(module);
	}


	Future Initialise({ void onError(String)? }) async
	{
		List<Future<TranslatableModule>> loading = [];

		// Retrieve values for current language and check if any expected values
		// are missing or unexpected values found
		for (var m in this._modules)
		{
			loading.add(LoadModule(m, null));
		}

		for (var l in loading)
		{
			var m = await l;

			if ((m.missing || m.orphaned) && onError != null)
			{
				onError(m.name);
			}
		}

		this._initialised.add(null);
	}

	// Implement this to retrieve a map of strings for a given module based on how data
	// is stored in your server-side application. If language is `null` then return
	// the values for the appropriate language based on the browser request header. If
	// language is a known code then return that language.
	Future<Map<String, String>> GetModuleEntries(String module, String? language);


	// Update a module with translations for a specific language or based on the browser
	// request header if language is `null`.
	Future<TranslatableModule> LoadModule(TranslatableModule module, String? language) async
	{
		var entries		= await GetModuleEntries(module.name, language);
		module.orphaned = entries.keys.any((k) => !module.values.containsKey(k));
		module.missing	= false;

		for (var k in module.values.keys)
		{
			if (entries.containsKey(k)) module.values[k]	= entries[k] ?? '';
			else						module.missing		= true;
		}

		return module;
	}

	// Load duplicates of all modules for a specific language. This can be used by a language
	// configuration component to provide an interface for modifying the language strings.
	Future<List<TranslatableModule>> Load(String language) async
	{
		List<TranslatableModule> result = [];
		List<Future<TranslatableModule>> loading = [];

		for (var m in this._modules)
		{
			loading.add(this.LoadModule(
				TranslatableModule.base(m.name, Map.from(m.values)),
				language
			));
		}

		for (var l in loading)
		{
			var module = await l;

			module.originals = Map.from(module.values);
			result.add(module);
		}

		return result;
	}

}
