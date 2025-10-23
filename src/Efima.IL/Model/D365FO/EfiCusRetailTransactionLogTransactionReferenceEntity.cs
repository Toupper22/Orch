using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactions entity
/// </summary>
[Entity("EfiCusRetailTransactionLogReferenceTransactions", 
    EntitySingularName = "EfiCusRetailTransactionLogReferenceTransaction",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Efima - Log reference lines.xml", "", "", "EfiCusRetailTransactionLogTransactionReferenceEntity")]
public class EfiCusRetailTransactionLogTransactionReferenceEntity : Entity
{
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
    public string RefOperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(RefOperatingUnitNumber));
        set => SetFieldValue(nameof(RefOperatingUnitNumber), value);
    }
    public string UploadType //TODO enum
    {
        get => GetFieldValue<string>(nameof(UploadType));
        set => SetFieldValue(nameof(UploadType), value);
    }
    public string TerminalId
    {
        get => GetFieldValue<string>(nameof(TerminalId));
        set => SetFieldValue(nameof(TerminalId), value);
    }
    public long? RetailLogId
    {
        get => GetFieldValue<long>(nameof(RetailLogId));
        set => SetFieldValue(nameof(RetailLogId), value);
    }
    public int? replicationCounterFromOrigin
    {
        get => GetFieldValue<int>(nameof(replicationCounterFromOrigin));
        set => SetFieldValue(nameof(replicationCounterFromOrigin), value);
    }
    public string RefTransactionId
    {
        get => GetFieldValue<string>(nameof(RefTransactionId));
        set => SetFieldValue(nameof(RefTransactionId), value);
    }
    public string RefTerminal
    {
        get => GetFieldValue<string>(nameof(RefTerminal));
        set => SetFieldValue(nameof(RefTerminal), value);
    }
    public long? ReferenceId
    {
        get => GetFieldValue<long>(nameof(ReferenceId));
        set => SetFieldValue(nameof(ReferenceId), value);
    }

}