namespace Efima.IL.Extensions;
using Azure;

using Efima.Core.Shared.Values;
using Efima.Core.Shared.Values.Conversions;
using Efima.Core.Shared.Values.Defaults;

using System.Threading.Tasks;

public static class ValuesServiceExtensions
{
    public static T GetConversionWithFallback<T>(this IValuesService svc, ConversionValueInfo<T> conversionValueInfo, string conversionKey, DefaultValueInfo<T> fallbackDefaultValueInfo = null)
    {
        if (fallbackDefaultValueInfo == null)
        {
            return svc.Get(conversionValueInfo, conversionKey);
        }
        else
        {
            return svc.TryGet(conversionValueInfo, conversionKey, out T result)
                ? result
                : svc.Get(fallbackDefaultValueInfo);
        }
    }

    public async static Task<string> GetSecretAsync(this IValuesService svc, string secretName, bool throwErrorIfNotFound = true)
    {
        string result = null;

        if (!string.IsNullOrEmpty(secretName))
            result = await svc.GetSecretValueAsync<string>(secretName, false);

        if (result == null && throwErrorIfNotFound)
            throw new RequestFailedException($"Secret '{secretName}' could not be found in KeyVault - check KeyVault connection and secret naming");

        return result;
    }
}
