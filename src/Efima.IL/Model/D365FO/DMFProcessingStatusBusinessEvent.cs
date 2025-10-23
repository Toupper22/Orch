namespace Efima.IL.Model.D365FO;

public class DMFProcessingStatusBusinessEvent
{
    public string BusinessEventId;
    public ulong ControlNumber;
    public string DMFDefinitionGroup;
    public string DMFExecutionId;
    public string EventId; // Guid
    public string EventTime;
    public string IntegrationActivityId; // Guid
    public int MajorVersion;
    public int MinorVersion;
    public string ProcessingSuccess; // NoYes
    public string RelatedEntityRecordEfiLinkId; // Guid
}
