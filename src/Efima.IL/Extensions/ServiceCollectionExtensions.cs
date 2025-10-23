namespace Efima.IL.Extensions;
using Efima.Core.Shared.Azure.Values.Conversions;
using Efima.Core.Shared.Azure.Values.Defaults;
using Efima.Core.Shared.Values;
using Efima.Core.Shared.Values.Env;
using Efima.IL;
using Microsoft.Extensions.DependencyInjection;

using System.Linq;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddValueServices(this IServiceCollection services, DemoValuesBase valueInstance)
    {
        services.AddEnvValueService(valueInstance.EnvVars);

        services.AddClassicTableDefaultValueService(
            valueInstance.Defaults,
            valueInstance.GenericStorageConnection,
            valueInstance.GenericDefaultsTableName,
            valueInstance.BlobConnectionString,
            valueInstance.InterfaceDefaultsTableName,
            cacheValues: true,
            recreateMissedOnRefresh: false,
            createTableIfNotExists: false);

        services.AddClassicTableConversionValueService(
            valueInstance.Conversions,
            valueInstance.GenericStorageConnection,
            valueInstance.GenericConversionsTableName,
            valueInstance.BlobConnectionString,
            valueInstance.InterfaceConversionsTableName,
            cacheValues: true,
            recreateMissedOnRefresh: false,
            createTableIfNotExists: false);

        return services.AddValuesService();
    }
}
