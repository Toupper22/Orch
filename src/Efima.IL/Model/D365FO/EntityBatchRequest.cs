using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;


namespace Efima.IL.Model.D365FO;

public class EntityBatchRequest
{
	public string ManifestFilename { get; set; } = "Manifest.xml";

	public string PostJournal { get; set; }

	public string KeepJournalOnPostingError { get; set; }

	public Batch Batch { get; set; }

	public int ODataMaxItems { get; set; }

	public string WorkflowName { get; set; }

	public string WorkflowRunId { get; set; }
}
