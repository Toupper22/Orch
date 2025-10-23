using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Web;

namespace Efima.IL.Utils;

public static class HelperUtils
{
	public static string? TryGetQueryParam(this HttpRequestMessage request, string paramName)
	{
		return HttpUtility.ParseQueryString(request.RequestUri.Query)[paramName];
	}

	public static string GetQueryParam(this HttpRequestMessage request, string paramName)
	{
		string val = HttpUtility.ParseQueryString(request.RequestUri.Query)[paramName];
		if (string.IsNullOrEmpty(val))
		{
			throw new ArgumentNullException(paramName);
		}
		return val;
	}

	public static void ValidateEnvironmentVariables(ICollection<string> listOfVars)
	{
		var sb = new StringBuilder();

		foreach (var variable in listOfVars)
		{
			if (string.IsNullOrEmpty(Environment.GetEnvironmentVariable(variable)))
				sb.Append($"Check that you have environment variable set: '{variable}'");
		}

		if (!string.IsNullOrEmpty(sb.ToString()))
			throw new Exception(sb.ToString());
	}
}
