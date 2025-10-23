using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactionDiscountLines entity
/// </summary>
[Entity("RetailTransactionDiscountLines", EntitySingularName = "RetailTransactionDiscountLine",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Discount transactions.xml", "", "", "RetailTransactionDiscountLineEntity")]
public class RetailTransactionDiscountLineEntity : Entity
{
    public decimal? EffectiveAmount
    {
        get => GetFieldValue<decimal>(nameof(EffectiveAmount));
        set => SetFieldValue(nameof(EffectiveAmount), value);
    }

    public string CustomerDiscountType //TODO enum
    {
        get => GetFieldValue<string>(nameof(CustomerDiscountType));
        set => SetFieldValue(nameof(CustomerDiscountType), value);
    }
    public decimal? DealPrice
    {
        get => GetFieldValue<decimal>(nameof(DealPrice));
        set => SetFieldValue(nameof(DealPrice), value);
    }
    public decimal? DiscountAmount
    {
        get => GetFieldValue<decimal>(nameof(DiscountAmount));
        set => SetFieldValue(nameof(DiscountAmount), value);
    }
    public string DiscountCode
    {
        get => GetFieldValue<string>(nameof(DiscountCode));
        set => SetFieldValue(nameof(DiscountCode), value);
    }
    public decimal? DiscountCost
    {
        get => GetFieldValue<decimal>(nameof(DiscountCost));
        set => SetFieldValue(nameof(DiscountCost), value);
    }
    public string DiscountOriginType //TODO enum
    {
        get => GetFieldValue<string>(nameof(DiscountOriginType));
        set => SetFieldValue(nameof(DiscountOriginType), value);
    }
    public decimal? LineNumber
    {
        get => GetFieldValue<decimal>(nameof(LineNumber));
        set => SetFieldValue(nameof(LineNumber), value);
    }
    public string ManualDiscountType //TODO enum
    {
        get => GetFieldValue<string>(nameof(ManualDiscountType));
        set => SetFieldValue(nameof(ManualDiscountType), value);
    }
    public decimal? DiscountPercentage
    {
        get => GetFieldValue<decimal>(nameof(DiscountPercentage));
        set => SetFieldValue(nameof(DiscountPercentage), value);
    }
    public string DiscountOfferId
    {
        get => GetFieldValue<string>(nameof(DiscountOfferId));
        set => SetFieldValue(nameof(DiscountOfferId), value);
    }
    public decimal? SalesLineNumber
    {
        get => GetFieldValue<decimal>(nameof(SalesLineNumber));
        set => SetFieldValue(nameof(SalesLineNumber), value);
    }
    public int? BundleId
    {
        get => GetFieldValue<int>(nameof(BundleId));
        set => SetFieldValue(nameof(BundleId), value);
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
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
}