namespace Efima.IL.Model.D365FO;
using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;

public class LedgerJournalDmfRecurringRequest
{
    public string RecurringActivityId { get; set; }
    public string ManifestXml { get; set; }

    public string PackageHeaderXml { get; set; }

    public EfiLedgerJournalHeaderEntity LedgerJournalHeaderEntity { get; set; }

}
