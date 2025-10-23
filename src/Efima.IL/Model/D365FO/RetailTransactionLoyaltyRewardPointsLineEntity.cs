using System;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactionBankedTenderTransEntity entity
/// </summary>
[Entity("RetailTransactionLoyaltyRewardPointsLines", EntitySingularName = "RetailTransactionLoyaltyRewardPointsLine",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Loyalty reward point transaction.xml", "", "", "RetailTransactionLoyaltyRewardPointsLineEntity")]
public class RetailTransactionLoyaltyRewardPointsLineEntity : Entity
{
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
    public string LoyaltyCardNumber
    {
        get => GetFieldValue<string>(nameof(LoyaltyCardNumber));
        set => SetFieldValue(nameof(LoyaltyCardNumber), value);
    }
    public string CustomerAccountNumber
    {
        get => GetFieldValue<string>(nameof(CustomerAccountNumber));
        set => SetFieldValue(nameof(CustomerAccountNumber), value);
    }
    public DateOnly? EntryDate
    {
        get => GetFieldValue<DateOnly>(nameof(EntryDate));
        set => SetFieldValue(nameof(EntryDate), value);
    }
    public TimeOnly? EntryTime
    {
        get => GetFieldValue<TimeOnly>(nameof(EntryTime));
        set => SetFieldValue(nameof(EntryTime), value);
    }
    public string EntryType //TODO enum
    {
        get => GetFieldValue<string>(nameof(EntryType));
        set => SetFieldValue(nameof(EntryType), value);
    }
    public DateOnly? ExpirationDate
    {
        get => GetFieldValue<DateOnly>(nameof(ExpirationDate));
        set => SetFieldValue(nameof(ExpirationDate), value);
    }
    public decimal? LineNumber
    {
        get => GetFieldValue<decimal>(nameof(LineNumber));
        set => SetFieldValue(nameof(LineNumber), value);
    }
    public string ReceiptNumber
    {
        get => GetFieldValue<string>(nameof(ReceiptNumber));
        set => SetFieldValue(nameof(ReceiptNumber), value);
    }
    public decimal? RewardPoints
    {
        get => GetFieldValue<decimal>(nameof(RewardPoints));
        set => SetFieldValue(nameof(RewardPoints), value);
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
    public string RewardPointId
    {
        get => GetFieldValue<string>(nameof(RewardPointId));
        set => SetFieldValue(nameof(RewardPointId), value);
    }
    public string LoyaltyTierId
    {
        get => GetFieldValue<string>(nameof(LoyaltyTierId));
        set => SetFieldValue(nameof(LoyaltyTierId), value);
    }
    public string LoyaltyName
    {
        get => GetFieldValue<string>(nameof(LoyaltyName));
        set => SetFieldValue(nameof(LoyaltyName), value);
    }
    public decimal? RetailTransactionSalesTransLineNum
    {
        get => GetFieldValue<decimal>(nameof(RetailTransactionSalesTransLineNum));
        set => SetFieldValue(nameof(RetailTransactionSalesTransLineNum), value);
    }
}