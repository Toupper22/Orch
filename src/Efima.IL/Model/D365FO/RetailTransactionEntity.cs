using System;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactions entity
/// </summary>
[Entity("RetailTransactions", EntitySingularName = "RetailTransaction",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Transactions.xml", "", "", "RetailTransactionEntity")]
public class RetailTransactionEntity : Entity
{
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
    public string BatchID
    {
        get => GetFieldValue<string>(nameof(BatchID));
        set => SetFieldValue(nameof(BatchID), value);
    }
    public string Terminal
    {
        get => GetFieldValue<string>(nameof(Terminal));
        set => SetFieldValue(nameof(Terminal), value);
    }
    public decimal? AmountPostedToAccount
    {
        get => GetFieldValue<decimal>(nameof(AmountPostedToAccount));
        set => SetFieldValue(nameof(AmountPostedToAccount), value);
    }
    public string ChannelReferenceId
    {
        get => GetFieldValue<string>(nameof(ChannelReferenceId));
        set => SetFieldValue(nameof(ChannelReferenceId), value);
    }
    public decimal? CostAmount
    {
        get => GetFieldValue<decimal>(nameof(CostAmount));
        set => SetFieldValue(nameof(CostAmount), value);
    }
    public NoYes? CreatedOffline
    {
        get => GetFieldValue<NoYes>(nameof(CreatedOffline));
        set => SetFieldValue(nameof(CreatedOffline), value);
    }
    public string Currency
    {
        get => GetFieldValue<string>(nameof(Currency));
        set => SetFieldValue(nameof(Currency), value);
    }
    public string CustomerAccount
    {
        get => GetFieldValue<string>(nameof(CustomerAccount));
        set => SetFieldValue(nameof(CustomerAccount), value);
    }
    public decimal? CustomerDiscountAmount
    {
        get => GetFieldValue<decimal>(nameof(CustomerDiscountAmount));
        set => SetFieldValue(nameof(CustomerDiscountAmount), value);
    }
    public decimal? DiscountAmount
    {
        get => GetFieldValue<decimal>(nameof(DiscountAmount));
        set => SetFieldValue(nameof(DiscountAmount), value);
    }
    public decimal? DiscountAmountWithoutTax
    {
        get => GetFieldValue<decimal>(nameof(DiscountAmountWithoutTax));
        set => SetFieldValue(nameof(DiscountAmountWithoutTax), value);
    }
    public string DeliveryMode
    {
        get => GetFieldValue<string>(nameof(DeliveryMode));
        set => SetFieldValue(nameof(DeliveryMode), value);
    }
    public string TransactionStatus //TODO enum
    {
        get => GetFieldValue<string>(nameof(TransactionStatus));
        set => SetFieldValue(nameof(TransactionStatus), value);
    }
    public decimal? ExchangeRate
    {
        get => GetFieldValue<decimal>(nameof(ExchangeRate));
        set => SetFieldValue(nameof(ExchangeRate), value);
    }
    public decimal? GrossAmount
    {
        get => GetFieldValue<decimal>(nameof(GrossAmount));
        set => SetFieldValue(nameof(GrossAmount), value);
    }
    public decimal? IncomeExpenseAmount
    {
        get => GetFieldValue<decimal>(nameof(IncomeExpenseAmount));
        set => SetFieldValue(nameof(IncomeExpenseAmount), value);
    }
    
    public string InfocodeDiscountGroup
    {
        get => GetFieldValue<string>(nameof(InfocodeDiscountGroup));
        set => SetFieldValue(nameof(InfocodeDiscountGroup), value);
    }
    public string Warehouse
    {
        get => GetFieldValue<string>(nameof(Warehouse));
        set => SetFieldValue(nameof(Warehouse), value);
    }
    public string SiteId
    {
        get => GetFieldValue<string>(nameof(SiteId));
        set => SetFieldValue(nameof(SiteId), value);
    }
    public string InvoiceId
    {
        get => GetFieldValue<string>(nameof(InvoiceId));
        set => SetFieldValue(nameof(InvoiceId), value);
    }
    public NoYes? ItemsPosted
    {
        get => GetFieldValue<NoYes>(nameof(ItemsPosted));
        set => SetFieldValue(nameof(ItemsPosted), value);
    }
    public string LoyaltyCardId
    {
        get => GetFieldValue<string>(nameof(LoyaltyCardId));
        set => SetFieldValue(nameof(LoyaltyCardId), value);
    }
    public decimal? NetAmount
    {
        get => GetFieldValue<decimal>(nameof(NetAmount));
        set => SetFieldValue(nameof(NetAmount), value);
    }
    public decimal? NetPrice
    {
        get => GetFieldValue<decimal>(nameof(NetPrice));
        set => SetFieldValue(nameof(NetPrice), value);
    }
    public decimal? PaymentAmount
    {
        get => GetFieldValue<decimal>(nameof(PaymentAmount));
        set => SetFieldValue(nameof(PaymentAmount), value);
    }
    public NoYes? PostAsShipment
    {
        get => GetFieldValue<NoYes>(nameof(PostAsShipment));
        set => SetFieldValue(nameof(PostAsShipment), value);
    }
    public string RreceiptId
    {
        get => GetFieldValue<string>(nameof(RreceiptId));
        set => SetFieldValue(nameof(RreceiptId), value);
    }
    public string RefundReceiptId
    {
        get => GetFieldValue<string>(nameof(RefundReceiptId));
        set => SetFieldValue(nameof(RefundReceiptId), value);
    }
    public NoYes? SaleIsReturnSale
    {
        get => GetFieldValue<NoYes>(nameof(SaleIsReturnSale));
        set => SetFieldValue(nameof(SaleIsReturnSale), value);
    }
    public decimal? SalesInvoiceAmount
    {
        get => GetFieldValue<decimal>(nameof(SalesInvoiceAmount));
        set => SetFieldValue(nameof(SalesInvoiceAmount), value);
    }
    public decimal? SalesOrderAmount
    {
        get => GetFieldValue<decimal>(nameof(SalesOrderAmount));
        set => SetFieldValue(nameof(SalesOrderAmount), value);
    }
    public string SalesOrderId
    {
        get => GetFieldValue<string>(nameof(SalesOrderId));
        set => SetFieldValue(nameof(SalesOrderId), value);
    }
    public decimal? SalesPaymentDifference
    {
        get => GetFieldValue<decimal>(nameof(SalesPaymentDifference));
        set => SetFieldValue(nameof(SalesPaymentDifference), value);
    }
    public string Shift
    {
        get => GetFieldValue<string>(nameof(Shift));
        set => SetFieldValue(nameof(Shift), value);
    }
    public DateOnly? ShippingDateRequested
    {
        get => GetFieldValue<DateOnly>(nameof(ShippingDateRequested));
        set => SetFieldValue(nameof(ShippingDateRequested), value);
    }
    public string Staff
    {
        get => GetFieldValue<string>(nameof(Staff));
        set => SetFieldValue(nameof(Staff), value);
    }
    public NoYes? ToAccount
    {
        get => GetFieldValue<NoYes>(nameof(ToAccount));
        set => SetFieldValue(nameof(ToAccount), value);
    }
    public decimal? TotalDiscountAmount
    {
        get => GetFieldValue<decimal>(nameof(TotalDiscountAmount));
        set => SetFieldValue(nameof(TotalDiscountAmount), value);
    }
    public decimal? TotalManualDiscountAmount
    {
        get => GetFieldValue<decimal>(nameof(TotalManualDiscountAmount));
        set => SetFieldValue(nameof(TotalManualDiscountAmount), value);
    }
    public decimal? TotalManualDiscountPercentage
    {
        get => GetFieldValue<decimal>(nameof(TotalManualDiscountPercentage));
        set => SetFieldValue(nameof(TotalManualDiscountPercentage), value);
    }
    public string TransactionNumber
    {
        get => GetFieldValue<string>(nameof(TransactionNumber));
        set => SetFieldValue(nameof(TransactionNumber), value);
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
    public string TransactionType //TODO enum
    {
        get => GetFieldValue<string>(nameof(TransactionType));
        set => SetFieldValue(nameof(TransactionType), value);
    }
    public string Comment
    {
        get => GetFieldValue<string>(nameof(Comment));
        set => SetFieldValue(nameof(Comment), value);
    }
    public string TaxCalculationType //TODO enum
    {
        get => GetFieldValue<string>(nameof(TaxCalculationType));
        set => SetFieldValue(nameof(TaxCalculationType), value);
    }
    public string SuspendedTransactionId
    {
        get => GetFieldValue<string>(nameof(SuspendedTransactionId));
        set => SetFieldValue(nameof(SuspendedTransactionId), value);
    }
    public NoYes? SaleOnAccount
    {
        get => GetFieldValue<NoYes>(nameof(SaleOnAccount));
        set => SetFieldValue(nameof(SaleOnAccount), value);
    }
    public DateTime? GiftCardActiveFrom
    {
        get => GetFieldValue<DateTime>(nameof(GiftCardActiveFrom));
        set => SetFieldValue(nameof(GiftCardActiveFrom), value);
    }
    public decimal? GiftCardBalance
    {
        get => GetFieldValue<decimal>(nameof(GiftCardBalance));
        set => SetFieldValue(nameof(GiftCardBalance), value);
    }
    public DateOnly? GiftCardExpireDate
    {
        get => GetFieldValue<DateOnly>(nameof(GiftCardExpireDate));
        set => SetFieldValue(nameof(GiftCardExpireDate), value);
    }
    public string GiftCardHistoryDetails
    {
        get => GetFieldValue<string>(nameof(GiftCardHistoryDetails));
        set => SetFieldValue(nameof(GiftCardHistoryDetails), value);
    }
    public decimal? GiftCardIssueAmount
    {
        get => GetFieldValue<decimal>(nameof(GiftCardIssueAmount));
        set => SetFieldValue(nameof(GiftCardIssueAmount), value);
    }
    public string GiftCardIdMasked
    {
        get => GetFieldValue<string>(nameof(GiftCardIdMasked));
        set => SetFieldValue(nameof(GiftCardIdMasked), value);
    }
    public DateOnly? businessDate
    {
        get => GetFieldValue<DateOnly>(nameof(businessDate));
        set => SetFieldValue(nameof(businessDate), value);
    }
    public NoYes? IsTaxIncludedInPrice
    {
        get => GetFieldValue<NoYes>(nameof(IsTaxIncludedInPrice));
        set => SetFieldValue(nameof(IsTaxIncludedInPrice), value);
    }
    public string TransactionOrderType
    {
        get => GetFieldValue<string>(nameof(TransactionOrderType));
        set => SetFieldValue(nameof(TransactionOrderType), value);
    }
    public DateTime? BeginDateTime
    {
        get => GetFieldValue<DateTime>(nameof(BeginDateTime));
        set => SetFieldValue(nameof(BeginDateTime), value);
    }
    public decimal? NumberOfItemLines
    {
        get => GetFieldValue<decimal>(nameof(NumberOfItemLines));
        set => SetFieldValue(nameof(NumberOfItemLines), value);
    }
    public decimal? NumberOfItems
    {
        get => GetFieldValue<decimal>(nameof(NumberOfItems));
        set => SetFieldValue(nameof(NumberOfItems), value);
    }
    public int? NumberOfPaymentLines
    {
        get => GetFieldValue<int>(nameof(NumberOfPaymentLines));
        set => SetFieldValue(nameof(NumberOfPaymentLines), value);
    }
    public NoYes? IsTaxExemptedForPriceInclusive
    {
        get => GetFieldValue<NoYes>(nameof(IsTaxExemptedForPriceInclusive));
        set => SetFieldValue(nameof(IsTaxExemptedForPriceInclusive), value);
    }
    public string BatchTerminalId
    {
        get => GetFieldValue<string>(nameof(BatchTerminalId));
        set => SetFieldValue(nameof(BatchTerminalId), value);
    }
    public string CreatedOnPosTerminal
    {
        get => GetFieldValue<string>(nameof(CreatedOnPosTerminal));
        set => SetFieldValue(nameof(CreatedOnPosTerminal), value);
    }
    public string CustomerName
    {
        get => GetFieldValue<string>(nameof(CustomerName));
        set => SetFieldValue(nameof(CustomerName), value);
    }
    public string LanguageId
    {
        get => GetFieldValue<string>(nameof(LanguageId));
        set => SetFieldValue(nameof(LanguageId), value);
    }
    public DateOnly? QuotationExpiryDate
    {
        get => GetFieldValue<DateOnly>(nameof(QuotationExpiryDate));
        set => SetFieldValue(nameof(QuotationExpiryDate), value);
    }
}