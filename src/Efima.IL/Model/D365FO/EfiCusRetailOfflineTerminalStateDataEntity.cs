using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactionBankedTenderTransEntity entity
/// </summary>
[Entity("EfiCusRetailOfflineTerminalStateDataLines", EntitySingularName = "EfiCusRetailOfflineTerminalStateDataLine",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Efima - Offline terminal state data.xml", "", "", "EfiCusRetailOfflineTerminalStateDataEntity")]
public class EfiCusRetailOfflineTerminalStateDataEntity : Entity
{
    public string OfflineTerminalStateData
    {
        get => GetFieldValue<string>(nameof(OfflineTerminalStateData));
        set => SetFieldValue(nameof(OfflineTerminalStateData), value);
    }
    public int? ReplicationCounterFromOrigin
    {
        get => GetFieldValue<int>(nameof(ReplicationCounterFromOrigin));
        set => SetFieldValue(nameof(ReplicationCounterFromOrigin), value);
    }
    public string TerminalId
    {
        get => GetFieldValue<string>(nameof(TerminalId));
        set => SetFieldValue(nameof(TerminalId), value);
    }
    public long? RetailOfflineTerminalStateDataRecId
    {
        get => GetFieldValue<long>(nameof(RetailOfflineTerminalStateDataRecId));
        set => SetFieldValue(nameof(RetailOfflineTerminalStateDataRecId), value);
    }

}