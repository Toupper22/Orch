using System;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactionBankedTenderTransEntity entity
/// </summary>
[Entity("RetailPosBatches", EntitySingularName = "RetailPosBatch",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Shifts.xml", "", "", "RetailPosBatchEntity")]
public class RetailPosBatchEntity : Entity
{
    public string OperationUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperationUnitNumber));
        set => SetFieldValue(nameof(OperationUnitNumber), value);
    }
    public string Terminal
    {
        get => GetFieldValue<string>(nameof(Terminal));
        set => SetFieldValue(nameof(Terminal), value);
    }
    public string BatchShiftId
    {
        get => GetFieldValue<string>(nameof(BatchShiftId));
        set => SetFieldValue(nameof(BatchShiftId), value);
    }
    public DateOnly? CloseDate
    {
        get => GetFieldValue<DateOnly>(nameof(CloseDate));
        set => SetFieldValue(nameof(CloseDate), value);
    }
    public DateTime? CloseDateTimeUtc
    {
        get => GetFieldValue<DateTime>(nameof(CloseDateTimeUtc));
        set => SetFieldValue(nameof(CloseDateTimeUtc), value);
    }
    public string ClosedAtRegisterNumber
    {
        get => GetFieldValue<string>(nameof(ClosedAtRegisterNumber));
        set => SetFieldValue(nameof(ClosedAtRegisterNumber), value);
    }
    public TimeOnly? CloseTime
    {
        get => GetFieldValue<TimeOnly>(nameof(CloseTime));
        set => SetFieldValue(nameof(CloseTime), value);
    }
    public int? CustomerSalesCount
    {
        get => GetFieldValue<int>(nameof(CustomerSalesCount));
        set => SetFieldValue(nameof(CustomerSalesCount), value);
    }
    public decimal? DiscountTotalAmount
    {
        get => GetFieldValue<decimal>(nameof(DiscountTotalAmount));
        set => SetFieldValue(nameof(DiscountTotalAmount), value);
    }
    public int? LogonsCount
    {
        get => GetFieldValue<int>(nameof(LogonsCount));
        set => SetFieldValue(nameof(LogonsCount), value);
    }
    public int? NoSaleCount
    {
        get => GetFieldValue<int>(nameof(NoSaleCount));
        set => SetFieldValue(nameof(NoSaleCount), value);
    }
    public string LocationNumber
    {
        get => GetFieldValue<string>(nameof(LocationNumber));
        set => SetFieldValue(nameof(LocationNumber), value);
    }
    public decimal? PaidToAccountTotal
    {
        get => GetFieldValue<decimal>(nameof(PaidToAccountTotal));
        set => SetFieldValue(nameof(PaidToAccountTotal), value);
    }
    public NoYes? Posted
    {
        get => GetFieldValue<NoYes>(nameof(Posted));
        set => SetFieldValue(nameof(Posted), value);
    }
    public int? ReplicationCounter
    {
        get => GetFieldValue<int>(nameof(ReplicationCounter));
        set => SetFieldValue(nameof(ReplicationCounter), value);
    }
    public decimal? ReturnsTotal
    {
        get => GetFieldValue<decimal>(nameof(ReturnsTotal));
        set => SetFieldValue(nameof(ReturnsTotal), value);
    }
    public decimal? RoundedAmountTotal
    {
        get => GetFieldValue<decimal>(nameof(RoundedAmountTotal));
        set => SetFieldValue(nameof(RoundedAmountTotal), value);
    }
    public int? SalesCount
    {
        get => GetFieldValue<int>(nameof(SalesCount));
        set => SetFieldValue(nameof(SalesCount), value);
    }
    public decimal? SalesTotal
    {
        get => GetFieldValue<decimal>(nameof(SalesTotal));
        set => SetFieldValue(nameof(SalesTotal), value);
    }
    public string OperatorId
    {
        get => GetFieldValue<string>(nameof(OperatorId));
        set => SetFieldValue(nameof(OperatorId), value);
    }
    public DateOnly? StartDate
    {
        get => GetFieldValue<DateOnly>(nameof(StartDate));
        set => SetFieldValue(nameof(StartDate), value);
    }
    public DateTime? StartDateTimeUtc
    {
        get => GetFieldValue<DateTime>(nameof(StartDateTimeUtc));
        set => SetFieldValue(nameof(StartDateTimeUtc), value);
    }
    public TimeOnly? StartTime
    {
        get => GetFieldValue<TimeOnly>(nameof(StartTime));
        set => SetFieldValue(nameof(StartTime), value);
    }
    public string StatementId
    {
        get => GetFieldValue<string>(nameof(StatementId));
        set => SetFieldValue(nameof(StatementId), value);
    }
    public string Status //TODO enum
    {
        get => GetFieldValue<string>(nameof(Status));
        set => SetFieldValue(nameof(Status), value);
    }
    public decimal? TaxTotal
    {
        get => GetFieldValue<decimal>(nameof(TaxTotal));
        set => SetFieldValue(nameof(TaxTotal), value);
    }
    public int? TransactionsCount
    {
        get => GetFieldValue<int>(nameof(TransactionsCount));
        set => SetFieldValue(nameof(TransactionsCount), value);
    }
    public int? VoidsCount
    {
        get => GetFieldValue<int>(nameof(VoidsCount));
        set => SetFieldValue(nameof(VoidsCount), value);
    }
    public decimal? ItemsSold
    {
        get => GetFieldValue<decimal>(nameof(ItemsSold));
        set => SetFieldValue(nameof(ItemsSold), value);
    }
    public decimal? PriceOverrideTotal
    {
        get => GetFieldValue<decimal>(nameof(PriceOverrideTotal));
        set => SetFieldValue(nameof(PriceOverrideTotal), value);
    }
    public int? ReceiptCopiesCount
    {
        get => GetFieldValue<int>(nameof(ReceiptCopiesCount));
        set => SetFieldValue(nameof(ReceiptCopiesCount), value);
    }
    public decimal? ReceiptCopiesTotal
    {
        get => GetFieldValue<decimal>(nameof(ReceiptCopiesTotal));
        set => SetFieldValue(nameof(ReceiptCopiesTotal), value);
    }
    public int? ReturnsCount
    {
        get => GetFieldValue<int>(nameof(ReturnsCount));
        set => SetFieldValue(nameof(ReturnsCount), value);
    }
    public decimal? ReturnsGrandTotal
    {
        get => GetFieldValue<decimal>(nameof(ReturnsGrandTotal));
        set => SetFieldValue(nameof(ReturnsGrandTotal), value);
    }
    public decimal? SalesGrandTotal
    {
        get => GetFieldValue<decimal>(nameof(SalesGrandTotal));
        set => SetFieldValue(nameof(SalesGrandTotal), value);
    }
    public decimal? ServicesSoldQuantity
    {
        get => GetFieldValue<decimal>(nameof(ServicesSoldQuantity));
        set => SetFieldValue(nameof(ServicesSoldQuantity), value);
    }
    public int? SuspendedCount
    {
        get => GetFieldValue<int>(nameof(SuspendedCount));
        set => SetFieldValue(nameof(SuspendedCount), value);
    }
    public decimal? SuspendedTotal
    {
        get => GetFieldValue<decimal>(nameof(SuspendedTotal));
        set => SetFieldValue(nameof(SuspendedTotal), value);
    }
    public int? TrainingCount
    {
        get => GetFieldValue<int>(nameof(TrainingCount));
        set => SetFieldValue(nameof(TrainingCount), value);
    }
    public decimal? TrainingTotal
    {
        get => GetFieldValue<decimal>(nameof(TrainingTotal));
        set => SetFieldValue(nameof(TrainingTotal), value);
    }
    public string StoreNumber
    {
        get => GetFieldValue<string>(nameof(StoreNumber));
        set => SetFieldValue(nameof(StoreNumber), value);
    }
    public decimal? GiftCardsTotal
    {
        get => GetFieldValue<decimal>(nameof(GiftCardsTotal));
        set => SetFieldValue(nameof(GiftCardsTotal), value);
    }
    public decimal? VoidedSalesTotal
    {
        get => GetFieldValue<decimal>(nameof(VoidedSalesTotal));
        set => SetFieldValue(nameof(VoidedSalesTotal), value);
    }
    public decimal? ShiftReturnsTotal
    {
        get => GetFieldValue<decimal>(nameof(ShiftReturnsTotal));
        set => SetFieldValue(nameof(ShiftReturnsTotal), value);
    }
    public decimal? ShiftSalesTotal
    {
        get => GetFieldValue<decimal>(nameof(ShiftSalesTotal));
        set => SetFieldValue(nameof(ShiftSalesTotal), value);
    }
    public decimal? GiftCardCashOutTotal
    {
        get => GetFieldValue<decimal>(nameof(GiftCardCashOutTotal));
        set => SetFieldValue(nameof(GiftCardCashOutTotal), value);
    }
    public decimal? ChargeTotal
    {
        get => GetFieldValue<decimal>(nameof(ChargeTotal));
        set => SetFieldValue(nameof(ChargeTotal), value);
    }
    public int? ZeroSalesCount
    {
        get => GetFieldValue<int>(nameof(ZeroSalesCount));
        set => SetFieldValue(nameof(ZeroSalesCount), value);
    }
    public NoYes? HasPendingOfflineTransactions
    {
        get => GetFieldValue<NoYes>(nameof(HasPendingOfflineTransactions));
        set => SetFieldValue(nameof(HasPendingOfflineTransactions), value);
    }
    public long? ClosedAtBatchId
    {
        get => GetFieldValue<long>(nameof(ClosedAtBatchId));
        set => SetFieldValue(nameof(ClosedAtBatchId), value);
    }
}