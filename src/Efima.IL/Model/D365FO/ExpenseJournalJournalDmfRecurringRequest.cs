using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;

using System.Collections.Generic;

namespace Efima.IL.Model.D365FO;

public class ExpenseJournalDmfRecurringRequest
{
	public string RecurringActivityId { get; set; }
	public string ManifestXml { get; set; }
	public string PackageHeaderXml { get; set; }

	public string PostJournal { get; set; }
	public string KeepJournalOnPostingError { get; set; }
	public EfiExpenseJournalHeaderEntity ExpenseJournalHeaderEntity { get; set; }
	public ICollection<EfiExpenseJournalLineWithHeaderEntity> EfiExpenseJournalLineWithHeaderEntities { get; set; } = [];

	public string CallbackUrl { get; set; }
	public string CallbackFunctionsKey { get; set; }

	public string ExternalId { get; set; }
	public string WorkflowName { get; set; }
	public string WorkflowRunId { get; set; }
}
