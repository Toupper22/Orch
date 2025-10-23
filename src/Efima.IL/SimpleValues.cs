using Efima.Core.Shared.Values.Env;
using Efima.IL;

namespace Efima.IL;

public class SimpleValues : DemoValuesBase
{
    private const string PartitionName = "Function";

    public override string InterfacePartitionName => PartitionName;
    public override string InterfaceDefaultsTableName => GenericDefaultsTableName;
    public override string InterfaceConversionsTableName => GenericConversionsTableName;

    public static SimpleValues Instance { get; } = new SimpleValues();

    protected SimpleValues() : base([PartitionName])
    {
    }

    protected SimpleValues(string partition) : base([partition])
    {
    }
}