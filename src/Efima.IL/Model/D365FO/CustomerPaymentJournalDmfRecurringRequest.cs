namespace Efima.IL.Model.D365FO;

using Efima.IL.Extensions.D365FO.Model;

public class CustomerPaymentJournalDmfRecurringRequest
{
    public string RecurringActivityId { get; set; }
    public string ManifestXml { get; set; }
    public string PackageHeaderXml { get; set; }
    public string PostJournal { get; set; }
    public string KeepJournalOnPostingError { get; set; }
    public CustomerPaymentJournalHeaderEntity JournalHeaderEntity { get; set; }
    public string CallbackUrl { get; set; }
    public string CallbackFunctionsKey { get; set; }
}
