namespace Efima.IL.Utils;

using System.Collections.Generic;
using System.Linq;

public static class DimensionUtils
{
	/// <summary>
	/// Extract tokens of the form '{token}' from the given string.
	/// </summary>
	/// <returns>Sub-strings that appear as enclosed in curly brackets.</returns>
	public static IEnumerable<string> GetFormattingTokens(string input)
	{
		if (string.IsNullOrEmpty(input))
			return [];

		var result = new LinkedList<string>();
		int i = 0, j = 0;
		while (i < input.Length - 1 && (i = input.IndexOf('{', j)) != -1 && (j = input.IndexOf('}', ++i)) != -1)
		{
			result.AddLast(input.Substring(i, j - i));
		}
		return result;
	}
}
