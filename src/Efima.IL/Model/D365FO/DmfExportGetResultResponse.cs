namespace Efima.IL.Model.D365FO;
using Efima.Layer.D365F.GenericInterface.Core.Enums;

public class DmfExportGetResultResponse : Base64FileResponse
{
    public DmfExecutionSummaryStatus ExecutionStatus { get; set; }
}
