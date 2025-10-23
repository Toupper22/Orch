namespace Efima.IL.Model.D365FO;

using Efima.Layer.D365F.GenericInterface.Core.Model.Collections;

//TODO there can be generalised service for sending any collection
public class RetailTransactionsDmfRecurringRequest
{
    public string RecurringActivityId { get; set; }
    public string ManifestXml { get; set; }
    public string PackageHeaderXml { get; set; }
    public EntitiesCollection Entities { get; set; }

    public string ExternalId;
    public string WorkflowName;
    public string WorkflowRunId;
}
