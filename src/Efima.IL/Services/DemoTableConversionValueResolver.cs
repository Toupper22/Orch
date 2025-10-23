namespace Efima.IL.Services;
using System;
using System.Collections.Generic;
using System.Linq;

using Efima.Core.Shared.Azure.Values.Common;
using Efima.Core.Shared.Azure.Values.Conversions;
using Efima.Core.Shared.Values.Common.Resolvers;
using Efima.Core.Shared.Values.Conversions;
using Efima.Core.Shared.Values.Conversions.Resolvers;

public class DemoAzureTableConversionValueResolver : TableValueResolverBase<AzureConversionValueEntity>, IConversionValueResolver
{
    private readonly AzureTableSpecHolder[] _tableSpecHolders;
    protected IReadOnlyCollection<IConversionValueInfo> Collection { get; }

    /// <inheritdoc />
    public DemoAzureTableConversionValueResolver(
        IReadOnlyCollection<IConversionValueInfo> collection,
        bool refreshOnNotFound,
        bool recreateMissedOnRefresh,
        params AzureTableSpecHolder[] tableSpecHolders)
        : base(refreshOnNotFound, recreateMissedOnRefresh, tableSpecHolders.GetHolders)
    {
        Collection = collection ?? throw new ArgumentNullException(nameof(collection));
        _tableSpecHolders = tableSpecHolders;
    }

    /// <inheritdoc />
    public bool Resolve(string name, string key, IReadOnlyCollection<string> partitionKeys, out PartitionResolverValue resolverValue)
    {
        var ret = Resolve(partitionKeys, entity => entity.PropertyName == name && entity.Key == key, out var tablevalue);
        if (!ret)
        {
            ret = true;
            tablevalue = new TableResolverValue(
                key,
                partitionKeys.Count == 0 ? string.Empty : partitionKeys.First(),
                _tableSpecHolders.Length == 0 ? null : _tableSpecHolders[0].TableSpec);
        }

        resolverValue = tablevalue;
        return ret;
    }

    public bool ResolveNoDefaultValue(string name, string key, IReadOnlyCollection<string> partitionKeys, out PartitionResolverValue resolverValue)
    {
        var ret = Resolve(partitionKeys, entity => entity.PropertyName == name && entity.Key == key, out var tablevalue);
        resolverValue = tablevalue;
        return ret;
    }

    /// <inheritdoc />
    protected override bool IsEntityEquals(AzureConversionValueEntity existedEntity, AzureConversionValueEntity newEntity)
    {
        return existedEntity.PartitionKey == newEntity.PartitionKey &&
               existedEntity.PropertyName == newEntity.PropertyName &&
               existedEntity.Key == newEntity.Key;
    }

    /// <inheritdoc />
    protected override IEnumerable<AzureConversionValueEntity> GetAllTableEntities(ValueTableSpec tableSpec)
    {
        foreach (var info in Collection)
        {
            var partitionKeys = info.PartitionKeys.Intersect(tableSpec.PartitionKeys).ToList();
            foreach (var nameOptions in info.NameOptions.GenerateNames())
            {
                var propertyName = string.Join(SuffixSeparator, nameOptions.Select(no => no.Name));
                var keys = nameOptions.Last().Keys;
                foreach (var partitionKey in partitionKeys)
                {
                    foreach (var key in keys)
                    {
                        var value = key.DefaultValue ?? string.Empty;
                        yield return new AzureConversionValueEntity
                        {
                            PartitionKey = partitionKey,
                            RowKey = $"{propertyName}{SuffixSeparator}{key.Name}",
                            Key = key.Name,
                            PropertyName = propertyName,
                            Value = value
                        };
                    }
                }
            }
        }
    }
}
