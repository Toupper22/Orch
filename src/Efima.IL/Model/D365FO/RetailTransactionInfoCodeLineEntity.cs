using System;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactionInfoCodeLines entity
/// </summary>
[Entity("RetailTransactionInfoCodeLines", EntitySingularName = "RetailTransactionInfoCodeLine",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Info code transactions.xml", "", "", "RetailTransactionInfoCodeLineEntity")]
public class RetailTransactionInfoCodeLineEntity : Entity
{
    public decimal? Amount
    {
        get => GetFieldValue<decimal>(nameof(Amount));
        set => SetFieldValue(nameof(Amount), value);
    }
    public string InfoCodeId
    {
        get => GetFieldValue<string>(nameof(InfoCodeId));
        set => SetFieldValue(nameof(InfoCodeId), value);
    }
    public string InputType //TODO enum
    {
        get => GetFieldValue<string>(nameof(InputType));
        set => SetFieldValue(nameof(InputType), value);
    }
    public string ItemTender
    {
        get => GetFieldValue<string>(nameof(ItemTender));
        set => SetFieldValue(nameof(ItemTender), value);
    }
    public decimal? LineNumber
    {
        get => GetFieldValue<decimal>(nameof(LineNumber));
        set => SetFieldValue(nameof(LineNumber), value);
    }
    public decimal? ParentLineNumber
    {
        get => GetFieldValue<decimal>(nameof(ParentLineNumber));
        set => SetFieldValue(nameof(ParentLineNumber), value);
    }
    public string SourceCode
    {
        get => GetFieldValue<string>(nameof(SourceCode));
        set => SetFieldValue(nameof(SourceCode), value);
    }
    public string SourceCodeTwo
    {
        get => GetFieldValue<string>(nameof(SourceCodeTwo));
        set => SetFieldValue(nameof(SourceCodeTwo), value);
    }
    public string SourceCodeThree
    {
        get => GetFieldValue<string>(nameof(SourceCodeThree));
        set => SetFieldValue(nameof(SourceCodeThree), value);
    }
    public string SubInfoCodeId
    {
        get => GetFieldValue<string>(nameof(SubInfoCodeId));
        set => SetFieldValue(nameof(SubInfoCodeId), value);
    }
    public string Terminal
    {
        get => GetFieldValue<string>(nameof(Terminal));
        set => SetFieldValue(nameof(Terminal), value);
    }
    public string TransactionNumber
    {
        get => GetFieldValue<string>(nameof(TransactionNumber));
        set => SetFieldValue(nameof(TransactionNumber), value);
    }
    public string TransactionStatus //TODO enum
    {
        get => GetFieldValue<string>(nameof(TransactionStatus));
        set => SetFieldValue(nameof(TransactionStatus), value);
    }
    public string TransactionType //TODO enum
    {
        get => GetFieldValue<string>(nameof(TransactionType));
        set => SetFieldValue(nameof(TransactionType), value);
    }
    public ulong RetailChannelTableOMOperatingUnitID
    {
        get => GetFieldValue<ulong>(nameof(RetailChannelTableOMOperatingUnitID));
        set => SetFieldValue(nameof(RetailChannelTableOMOperatingUnitID), value);
    }
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
    public Guid? FiscalTransactionParentGuid
    {
        get => GetFieldValue<Guid>(nameof(FiscalTransactionParentGuid));
        set => SetFieldValue(nameof(FiscalTransactionParentGuid), value);
    }
    public DateOnly? businessDate
    {
        get => GetFieldValue<DateOnly>(nameof(businessDate));
        set => SetFieldValue(nameof(businessDate), value);
    }
    public decimal? infoAmount
    {
        get => GetFieldValue<decimal>(nameof(infoAmount));
        set => SetFieldValue(nameof(infoAmount), value);
    }
    public string information
    {
        get => GetFieldValue<string>(nameof(information));
        set => SetFieldValue(nameof(information), value);
    }
    public string staff
    {
        get => GetFieldValue<string>(nameof(staff));
        set => SetFieldValue(nameof(staff), value);
    }
    public DateOnly? transDate
    {
        get => GetFieldValue<DateOnly>(nameof(transDate));
        set => SetFieldValue(nameof(transDate), value);
    }
    public TimeOnly? transTime
    {
        get => GetFieldValue<TimeOnly>(nameof(transTime));
        set => SetFieldValue(nameof(transTime), value);
    }
    public string StoreNumber
    {
        get => GetFieldValue<string>(nameof(StoreNumber));
        set => SetFieldValue(nameof(StoreNumber), value);
    }
}