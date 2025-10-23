using Efima.Core.Shared.Values.Env;
using Efima.IL;

namespace Efima.Integration.Nomentia.Values;

public abstract class NomentiaValues : DemoValuesBase
{
    private const string PartitionName = "Nomentia";

    public override string InterfacePartitionName => PartitionName;
    public override string InterfaceDefaultsTableName => GenericDefaultsTableName;
    public override string InterfaceConversionsTableName => GenericConversionsTableName;

    protected NomentiaValues(string partition) : base(new[] { partition, PartitionName })
    {
    }
}