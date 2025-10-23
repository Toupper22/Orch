namespace Efima.IL.Services;
using System.Collections.Generic;

using Efima.Core.Shared.Values.Common;
using Efima.Core.Shared.Values.Conversions;
using Efima.Core.Shared.Values.Conversions.Resolvers;
using Efima.Layer.D365F.GenericInterface.Core.Utils.TypeConvert;

public class DemoConversionValueService : ConversionValueService
{
    public DemoConversionValueService(
        IConversionValueResolver resolver,
        ValueInfoCollection<IConversionValueInfo> infoCollection)
        : base(resolver, infoCollection)
    {
    }

    public override bool TryGetConversionValue<T>(string conversionValueName, string key, IReadOnlyCollection<string> partitionKeys, out T value)
    {
        if (Resolver is DemoAzureTableConversionValueResolver azureTableConversionValueResolver)
        {
            if (azureTableConversionValueResolver.ResolveNoDefaultValue(conversionValueName, key, partitionKeys, out var resolverValue) && resolverValue != null)
            {
                value = TypeConverter.ConvertTo<T>(resolverValue.Value);
                return true;
            }

            value = default;
            return false;
        }

        return base.TryGetConversionValue(conversionValueName, key, partitionKeys, out value);
    }
}
