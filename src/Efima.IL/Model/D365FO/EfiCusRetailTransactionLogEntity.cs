using System;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactions entity
/// </summary>
[Entity("EfiCusRetailTransactionLogTransactions",
    EntitySingularName = "EfiCusRetailTransactionLogTransaction",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Efima - Log lines.xml", "", "", "EfiCusRetailTransactionLogEntity")]
public class EfiCusRetailTransactionLogEntity : Entity
{
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
    public string UploadType //TODO enum
    {
        get => GetFieldValue<string>(nameof(UploadType));
        set => SetFieldValue(nameof(UploadType), value);
    }
    public string terminalId
    {
        get => GetFieldValue<string>(nameof(terminalId));
        set => SetFieldValue(nameof(terminalId), value);
    }
    public string StaffId
    {
        get => GetFieldValue<string>(nameof(StaffId));
        set => SetFieldValue(nameof(StaffId), value);
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
    public string Origin
    {
        get => GetFieldValue<string>(nameof(Origin));
        set => SetFieldValue(nameof(Origin), value);
    }
    public TimeOnly? LogTime
    {
        get => GetFieldValue<TimeOnly>(nameof(LogTime));
        set => SetFieldValue(nameof(LogTime), value);
    }
    public string LogString
    {
        get => GetFieldValue<string>(nameof(LogString));
        set => SetFieldValue(nameof(LogString), value);
    }
    public string LogLevel //TODO enum
    {
        get => GetFieldValue<string>(nameof(LogLevel));
        set => SetFieldValue(nameof(LogLevel), value);
    }
    public DateOnly? LogDate
    {
        get => GetFieldValue<DateOnly>(nameof(LogDate));
        set => SetFieldValue(nameof(LogDate), value);
    }
    public int? Id
    {
        get => GetFieldValue<int>(nameof(Id));
        set => SetFieldValue(nameof(Id), value);
    }
    public string EventType //TODO enum
    {
        get => GetFieldValue<string>(nameof(EventType));
        set => SetFieldValue(nameof(EventType), value);
    }
    public int? durationInMilliSec
    {
        get => GetFieldValue<int>(nameof(durationInMilliSec));
        set => SetFieldValue(nameof(durationInMilliSec), value);
    }
    public string CodeUnit
    {
        get => GetFieldValue<string>(nameof(CodeUnit));
        set => SetFieldValue(nameof(CodeUnit), value);
    }
    public long? ClosedBatchId
    {
        get => GetFieldValue<long>(nameof(ClosedBatchId));
        set => SetFieldValue(nameof(ClosedBatchId), value);
    }
    public long? BatchId
    {
        get => GetFieldValue<long>(nameof(BatchId));
        set => SetFieldValue(nameof(BatchId), value);
    }
}