namespace Efima.Integration.Nomentia.Values;

public class NomentiaBankStatementValues : NomentiaValues
{
    private const string PartitionName = "FunctionBankStatement";

    public static NomentiaBankStatementValues Instance { get; }
        = new NomentiaBankStatementValues(PartitionName);

    private NomentiaBankStatementValues(string partition)
        : base(partition)
    {
    }
}