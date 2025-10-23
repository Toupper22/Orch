namespace Efima.IL.Model.D365FO;
using Efima.Layer.D365F.GenericInterface.Core.Collections;
using Efima.Layer.D365F.GenericInterface.Core.Model;

public class SalesOrderDmfRecurringResponse
{
    public bool ProcessingSucceeded { get; set; }
    public EntityOperationCollection EntityOperations { get; set; }
    public DmfResponse DmfResponse { get; set; }
}
