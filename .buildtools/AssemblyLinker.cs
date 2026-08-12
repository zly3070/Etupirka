using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Reflection.Emit;
using System.Resources;
using System.Text.RegularExpressions;

internal static class AssemblyLinker
{
	private static int Main(string[] args)
	{
		try
		{
			string output = null;
			string culture = null;
			string template = null;
			Version version = new Version(0, 0, 0, 0);
			var resources = new List<KeyValuePair<string, string>>();

			foreach (string rawArgument in ExpandArguments(args))
			{
				string argument = TrimQuotes(rawArgument);
				if (TryGetValue(argument, "/out:", out string value))
				{
					output = value;
				}
				else if (TryGetValue(argument, "/culture:", out value))
				{
					culture = value;
				}
				else if (TryGetValue(argument, "/version:", out value))
				{
					Version.TryParse(value, out version);
				}
				else if (TryGetValue(argument, "/template:", out value))
				{
					template = value;
				}
				else if (TryGetValue(argument, "/embed:", out value))
				{
					ParseResource(value, resources);
				}
			}

			if (string.IsNullOrWhiteSpace(output))
			{
				throw new ArgumentException("Missing /out argument.");
			}

			Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(output)));
			if (!string.IsNullOrEmpty(template) && File.Exists(template))
			{
				version = AssemblyName.GetAssemblyName(template).Version;
			}

			string assemblyName = Path.GetFileNameWithoutExtension(output);
			var name = new AssemblyName(assemblyName)
			{
				CultureInfo = string.IsNullOrEmpty(culture) ? CultureInfo.InvariantCulture : CultureInfo.GetCultureInfo(culture),
				Version = version ?? new Version(0, 0, 0, 0)
			};

			AppDomain domain = AppDomain.CurrentDomain;
			AssemblyBuilder assembly = domain.DefineDynamicAssembly(name, AssemblyBuilderAccess.Save, Path.GetDirectoryName(Path.GetFullPath(output)));
			ModuleBuilder module = assembly.DefineDynamicModule(assemblyName, Path.GetFileName(output));
			foreach (var resource in resources)
			{
				module.DefineManifestResource(resource.Value, File.OpenRead(resource.Key), ResourceAttributes.Public);
			}

			assembly.Save(Path.GetFileName(output));
			return 0;
		}
		catch (Exception exception)
		{
			Console.Error.WriteLine("ALINK error: " + exception.Message);
			return 1;
		}
	}

	private static IEnumerable<string> ExpandArguments(IEnumerable<string> arguments)
	{
		foreach (string argument in arguments)
		{
			if (argument.StartsWith("@", StringComparison.Ordinal) && File.Exists(TrimQuotes(argument.Substring(1))))
			{
				string content = File.ReadAllText(TrimQuotes(argument.Substring(1)));
				foreach (Match match in Regex.Matches(content, "(?:[^\\s\\\"]|\\\"[^\\\"]*\\\")+"))
				{
					yield return match.Value;
				}
			}
			else
			{
				yield return argument;
			}
		}
	}

	private static bool TryGetValue(string argument, string prefix, out string value)
	{
		if (argument.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
		{
			value = TrimQuotes(argument.Substring(prefix.Length));
			return true;
		}

		value = null;
		return false;
	}

	private static void ParseResource(string value, List<KeyValuePair<string, string>> resources)
	{
		string[] parts = value.Split(new[] { ',' }, 3);
		string file = TrimQuotes(parts[0]);
		string name = parts.Length > 1 ? TrimQuotes(parts[1]) : Path.GetFileName(file);
		resources.Add(new KeyValuePair<string, string>(file, name));
	}

	private static string TrimQuotes(string value)
	{
		return value == null ? null : value.Trim().Trim('"');
	}
}
