using System;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for EfiCusRetailTransactionTenderDeclarationTransEntity entity
/// </summary>
[Entity("EfiCusRetailTransactionTenderDeclarationTransactions", EntitySingularName = "EfiCusRetailTransactionTenderDeclarationTransaction",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Efima - Tender declaration lines.xml", "", "", "EfiCusRetailTransactionTenderDeclarationTransEntity")]
public class EfiCusRetailTransactionTenderDeclarationTransEntity : Entity
{
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
    public decimal? amountCur
    {
        get => GetFieldValue<decimal>(nameof(amountCur));
        set => SetFieldValue(nameof(amountCur), value);
    }
    public decimal? amountMST
    {
        get => GetFieldValue<decimal>(nameof(amountMST));
        set => SetFieldValue(nameof(amountMST), value);
    }
    public decimal? amountTendered
    {
        get => GetFieldValue<decimal>(nameof(amountTendered));
        set => SetFieldValue(nameof(amountTendered), value);
    }
    public DateOnly? businessDate
    {
        get => GetFieldValue<DateOnly>(nameof(businessDate));
        set => SetFieldValue(nameof(businessDate), value);
    }
    public string cardId
    {
        get => GetFieldValue<string>(nameof(cardId));
        set => SetFieldValue(nameof(cardId), value);
    }
    public string currency
    {
        get => GetFieldValue<string>(nameof(currency));
        set => SetFieldValue(nameof(currency), value);
    }
    public decimal? exchRate
    {
        get => GetFieldValue<decimal>(nameof(exchRate));
        set => SetFieldValue(nameof(exchRate), value);
    }
    public decimal? exchRateMST
    {
        get => GetFieldValue<decimal>(nameof(exchRateMST));
        set => SetFieldValue(nameof(exchRateMST), value);
    }
    public decimal? lineNum
    {
        get => GetFieldValue<decimal>(nameof(lineNum));
        set => SetFieldValue(nameof(lineNum), value);
    }
    public string POSCurrency
    {
        get => GetFieldValue<string>(nameof(POSCurrency));
        set => SetFieldValue(nameof(POSCurrency), value);
    }
    public decimal? qty
    {
        get => GetFieldValue<decimal>(nameof(qty));
        set => SetFieldValue(nameof(qty), value);
    }
    public string receiptId
    {
        get => GetFieldValue<string>(nameof(receiptId));
        set => SetFieldValue(nameof(receiptId), value);
    }
    public NoYes? replicated
    {
        get => GetFieldValue<NoYes>(nameof(replicated));
        set => SetFieldValue(nameof(replicated), value);
    }
    public int? replicationCounterFromOrigin
    {
        get => GetFieldValue<int>(nameof(replicationCounterFromOrigin));
        set => SetFieldValue(nameof(replicationCounterFromOrigin), value);
    }
    public string shift
    {
        get => GetFieldValue<string>(nameof(shift));
        set => SetFieldValue(nameof(shift), value);
    }
    public DateOnly? shiftDate
    {
        get => GetFieldValue<DateOnly>(nameof(shiftDate));
        set => SetFieldValue(nameof(shiftDate), value);
    }
    public string staff
    {
        get => GetFieldValue<string>(nameof(staff));
        set => SetFieldValue(nameof(staff), value);
    }
    public string statementCode
    {
        get => GetFieldValue<string>(nameof(statementCode));
        set => SetFieldValue(nameof(statementCode), value);
    }
    public string statementId
    {
        get => GetFieldValue<string>(nameof(statementId));
        set => SetFieldValue(nameof(statementId), value);
    }
    public string store
    {
        get => GetFieldValue<string>(nameof(store));
        set => SetFieldValue(nameof(store), value);
    }
    public string tenderType
    {
        get => GetFieldValue<string>(nameof(tenderType));
        set => SetFieldValue(nameof(tenderType), value);
    }
    public string terminal
    {
        get => GetFieldValue<string>(nameof(terminal));
        set => SetFieldValue(nameof(terminal), value);
    }
    public string transactionId
    {
        get => GetFieldValue<string>(nameof(transactionId));
        set => SetFieldValue(nameof(transactionId), value);
    }
    public string transactionStatus //TODO enum
    {
        get => GetFieldValue<string>(nameof(transactionStatus));
        set => SetFieldValue(nameof(transactionStatus), value);
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
}