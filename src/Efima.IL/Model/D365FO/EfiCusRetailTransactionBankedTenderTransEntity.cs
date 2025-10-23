using System;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for EfiCusRetailTransactionBankedTenderTransactions entity
/// </summary>
[Entity("EfiCusRetailTransactionBankedTenderTransactions", EntitySingularName = "EfiCusRetailTransactionBankedTenderTransaction",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Efima - Banked tender transactions.xml", "", "", "EfiCusRetailTransactionBankedTenderTransEntity")]
public class EfiCusRetailTransactionBankedTenderTransEntity : Entity
{
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
    public decimal? AmountCurrency
    {
        get => GetFieldValue<decimal>(nameof(AmountCurrency));
        set => SetFieldValue(nameof(AmountCurrency), value);
    }
    public decimal? AmountCurrencyPOS
    {
        get => GetFieldValue<decimal>(nameof(AmountCurrencyPOS));
        set => SetFieldValue(nameof(AmountCurrencyPOS), value);
    }
    public decimal? AmountMST
    {
        get => GetFieldValue<decimal>(nameof(AmountMST));
        set => SetFieldValue(nameof(AmountMST), value);
    }
    public decimal? AmountMSTPOS
    {
        get => GetFieldValue<decimal>(nameof(AmountMSTPOS));
        set => SetFieldValue(nameof(AmountMSTPOS), value);
    }
    public decimal? AmountTendered
    {
        get => GetFieldValue<decimal>(nameof(AmountTendered));
        set => SetFieldValue(nameof(AmountTendered), value);
    }
    public decimal? AmountTenderedPOS
    {
        get => GetFieldValue<decimal>(nameof(AmountTenderedPOS));
        set => SetFieldValue(nameof(AmountTenderedPOS), value);
    }
    public string BankBagNumber
    {
        get => GetFieldValue<string>(nameof(BankBagNumber));
        set => SetFieldValue(nameof(BankBagNumber), value);
    }
    public DateOnly? BusinessDate
    {
        get => GetFieldValue<DateOnly>(nameof(BusinessDate));
        set => SetFieldValue(nameof(BusinessDate), value);
    }
    public string CardOrAccount
    {
        get => GetFieldValue<string>(nameof(CardOrAccount));
        set => SetFieldValue(nameof(CardOrAccount), value);
    }
    public string CardTypeId
    {
        get => GetFieldValue<string>(nameof(CardTypeId));
        set => SetFieldValue(nameof(CardTypeId), value);
    }
    public NoYes? ChangeLine
    {
        get => GetFieldValue<NoYes>(nameof(ChangeLine));
        set => SetFieldValue(nameof(ChangeLine), value);
    }
    public decimal? Counter
    {
        get => GetFieldValue<decimal>(nameof(Counter));
        set => SetFieldValue(nameof(Counter), value);
    }
    public string Currency
    {
        get => GetFieldValue<string>(nameof(Currency));
        set => SetFieldValue(nameof(Currency), value);
    }
    public decimal? ExchangeRate
    {
        get => GetFieldValue<decimal>(nameof(ExchangeRate));
        set => SetFieldValue(nameof(ExchangeRate), value);
    }
    public decimal? ExchangeRateMST
    {
        get => GetFieldValue<decimal>(nameof(ExchangeRateMST));
        set => SetFieldValue(nameof(ExchangeRateMST), value);
    }
    public decimal? LineNumber
    {
        get => GetFieldValue<decimal>(nameof(LineNumber));
        set => SetFieldValue(nameof(LineNumber), value);
    }
    public NoYes? ManagersKeyLive
    {
        get => GetFieldValue<NoYes>(nameof(ManagersKeyLive));
        set => SetFieldValue(nameof(ManagersKeyLive), value);
    }
    public int? MessageNumber
    {
        get => GetFieldValue<int>(nameof(MessageNumber));
        set => SetFieldValue(nameof(MessageNumber), value);
    }
    public decimal? Quantity
    {
        get => GetFieldValue<decimal>(nameof(Quantity));
        set => SetFieldValue(nameof(Quantity), value);
    }
    public NoYes? Replicated
    {
        get => GetFieldValue<NoYes>(nameof(Replicated));
        set => SetFieldValue(nameof(Replicated), value);
    }
    public string Shift
    {
        get => GetFieldValue<string>(nameof(Shift));
        set => SetFieldValue(nameof(Shift), value);
    }
    public DateOnly? ShiftDate
    {
        get => GetFieldValue<DateOnly>(nameof(ShiftDate));
        set => SetFieldValue(nameof(ShiftDate), value);
    }
    public string Staff
    {
        get => GetFieldValue<string>(nameof(Staff));
        set => SetFieldValue(nameof(Staff), value);
    }
    public string StatementCode
    {
        get => GetFieldValue<string>(nameof(StatementCode));
        set => SetFieldValue(nameof(StatementCode), value);
    }
    public string StatementId
    {
        get => GetFieldValue<string>(nameof(StatementId));
        set => SetFieldValue(nameof(StatementId), value);
    }
    public string BankedStatusType //TODO enum
    {
        get => GetFieldValue<string>(nameof(BankedStatusType));
        set => SetFieldValue(nameof(BankedStatusType), value);
    }
    public string StoreNumber
    {
        get => GetFieldValue<string>(nameof(StoreNumber));
        set => SetFieldValue(nameof(StoreNumber), value);
    }
    public string TenderType
    {
        get => GetFieldValue<string>(nameof(TenderType));
        set => SetFieldValue(nameof(TenderType), value);
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
    public DateOnly? TransactionDate
    {
        get => GetFieldValue<DateOnly>(nameof(TransactionDate));
        set => SetFieldValue(nameof(TransactionDate), value);
    }
    public TimeOnly? TransactionTime
    {
        get => GetFieldValue<TimeOnly>(nameof(TransactionTime));
        set => SetFieldValue(nameof(TransactionTime), value);
    }

}