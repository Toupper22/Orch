namespace Efima.IL.Model.D365FO;
using Efima.Layer.D365F.GenericInterface.Core.Model.Collections;

public class CustomersDmfRecurringRequest
{
    public string RecurringActivityId { get; set; }
    public string ManifestXml { get; set; }
    public string PackageHeaderXml { get; set; }
    public EntitiesCollection CustomerEntities { get; set; }

    public string CallbackUrl { get; set; }
    public string CallbackFunctionsKey { get; set; }
}
