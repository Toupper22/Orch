using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactionPaymentLinesV2 entity
/// </summary>
[Entity("RetailTransactionPaymentLinesV2", EntitySingularName = "RetailTransactionSalesLineV2",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Payment transactions V2.xml", "", "", "RetailTransactionPaymentLineV2Entity")]
public class RetailTransactionPaymentLineV2Entity : Entity
{
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
    public decimal? AmountInAccountingCurrency
    {
        get => GetFieldValue<decimal>(nameof(AmountInAccountingCurrency));
        set => SetFieldValue(nameof(AmountInAccountingCurrency), value);
    }

    public decimal? AmountInTenderedCurrency
    {
        get => GetFieldValue<decimal>(nameof(AmountInTenderedCurrency));
        set => SetFieldValue(nameof(AmountInTenderedCurrency), value);
    }

    public decimal? AmountTendered
    {
        get => GetFieldValue<decimal>(nameof(AmountTendered));
        set => SetFieldValue(nameof(AmountTendered), value);
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

    public string CreditVoucherId
    {
        get => GetFieldValue<string>(nameof(CreditVoucherId));
        set => SetFieldValue(nameof(CreditVoucherId), value);
    }

    public string CurrencyCode
    {
        get => GetFieldValue<string>(nameof(CurrencyCode));
        set => SetFieldValue(nameof(CurrencyCode), value);
    }

    public decimal? ExchangeRateInAccountingCurrency
    {
        get => GetFieldValue<decimal>(nameof(ExchangeRateInAccountingCurrency));
        set => SetFieldValue(nameof(ExchangeRateInAccountingCurrency), value);
    }

    public decimal? ExchangeRateInTenderedCurrency
    {
        get => GetFieldValue<decimal>(nameof(ExchangeRateInTenderedCurrency));
        set => SetFieldValue(nameof(ExchangeRateInTenderedCurrency), value);
    }

    public string GiftCardId
    {
        get => GetFieldValue<string>(nameof(GiftCardId));
        set => SetFieldValue(nameof(GiftCardId), value);
    }

    public NoYes? IsChangeLine
    {
        get => GetFieldValue<NoYes>(nameof(IsChangeLine));
        set => SetFieldValue(nameof(IsChangeLine), value);
    }

    public NoYes? IsLinkedRefund
    {
        get => GetFieldValue<NoYes>(nameof(IsLinkedRefund));
        set => SetFieldValue(nameof(IsLinkedRefund), value);
    }

    public NoYes? IsPrepayment
    {
        get => GetFieldValue<NoYes>(nameof(IsPrepayment));
        set => SetFieldValue(nameof(IsPrepayment), value);
    }

    public decimal? LineNumber
    {
        get => GetFieldValue<decimal>(nameof(LineNumber));
        set => SetFieldValue(nameof(LineNumber), value);
    }

    public decimal? LinkedPaymentLineNumber
    {
        get => GetFieldValue<decimal>(nameof(LinkedPaymentLineNumber));
        set => SetFieldValue(nameof(LinkedPaymentLineNumber), value);
    }

    public string LinkedPaymentStore
    {
        get => GetFieldValue<string>(nameof(LinkedPaymentStore));
        set => SetFieldValue(nameof(LinkedPaymentStore), value);
    }

    public string LinkedPaymentTerminal
    {
        get => GetFieldValue<string>(nameof(LinkedPaymentTerminal));
        set => SetFieldValue(nameof(LinkedPaymentTerminal), value);
    }

    public string LinkedPaymentTransactionNumber
    {
        get => GetFieldValue<string>(nameof(LinkedPaymentTransactionNumber));
        set => SetFieldValue(nameof(LinkedPaymentTransactionNumber), value);
    }

    public string LinkedPaymentCurrency
    {
        get => GetFieldValue<string>(nameof(LinkedPaymentCurrency));
        set => SetFieldValue(nameof(LinkedPaymentCurrency), value);
    }

    public string LoyaltyCardId
    {
        get => GetFieldValue<string>(nameof(LoyaltyCardId));
        set => SetFieldValue(nameof(LoyaltyCardId), value);
    }

    public string ReceiptId
    {
        get => GetFieldValue<string>(nameof(ReceiptId));
        set => SetFieldValue(nameof(ReceiptId), value);
    }

    public decimal? RefundableAmount
    {
        get => GetFieldValue<decimal>(nameof(RefundableAmount));
        set => SetFieldValue(nameof(RefundableAmount), value);
    }

    public string PaymentCaptureToken
    {
        get => GetFieldValue<string>(nameof(PaymentCaptureToken));
        set => SetFieldValue(nameof(PaymentCaptureToken), value);
    }

    public decimal? Quantity
    {
        get => GetFieldValue<decimal>(nameof(Quantity));
        set => SetFieldValue(nameof(Quantity), value);
    }

    public string Staff
    {
        get => GetFieldValue<string>(nameof(Staff));
        set => SetFieldValue(nameof(Staff), value);
    }

    public string Store
    {
        get => GetFieldValue<string>(nameof(Store));
        set => SetFieldValue(nameof(Store), value);
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

    public string VoidStatus //TODO enum
    {
        get => GetFieldValue<string>(nameof(VoidStatus));
        set => SetFieldValue(nameof(VoidStatus), value);
    }

    public NoYes? IsPaymentCaptured
    {
        get => GetFieldValue<NoYes>(nameof(IsPaymentCaptured));
        set => SetFieldValue(nameof(IsPaymentCaptured), value);
    }
}