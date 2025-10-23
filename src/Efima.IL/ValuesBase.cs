using System.Linq;
using Efima.Core.Shared.Values;
using Efima.Core.Shared.Values.Env;

namespace Efima.IL;

public abstract class DemoValuesBase : ValuesInfoCollection
{
    private const string PartitionName = EfimaTablePartitions.GenericPartition;
    private const string DefaultsTableName = "Values";
    private const string ConversionsTableName = "Conversions";

    public virtual string GenericPartitionName => PartitionName;
    public virtual string GenericDefaultsTableName => DefaultsTableName;
    public virtual string GenericConversionsTableName => ConversionsTableName;

    public abstract string InterfacePartitionName { get; }
    public abstract string InterfaceDefaultsTableName { get; }
    public abstract string InterfaceConversionsTableName { get; }

    public virtual EnvValueInfo<string> GenericStorageConnection { get; }
    public virtual EnvValueInfo<string> BlobConnectionString { get; }


    protected DemoValuesBase(string[] partitionKeys)
        : base(partitionKeys.Concat(new[] { PartitionName }).ToArray())
    {
        //ConnectionStrings
        GenericStorageConnection = BlobConnectionString = EnvVars.CreateStr(nameof(BlobConnectionString), null);
    }
}