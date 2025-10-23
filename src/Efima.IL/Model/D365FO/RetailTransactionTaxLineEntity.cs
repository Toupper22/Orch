using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactions entity
/// </summary>
[Entity("RetailTransactionTaxLines", EntitySingularName = "RetailTransactionTaxLine",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Tax transactions.xml", "", "", "RetailTransactionTaxLineEntity")]
public class RetailTransactionTaxLineEntity : Entity
{
    public decimal? TaxAmount
    {
        get => GetFieldValue<decimal>(nameof(TaxAmount));
        set => SetFieldValue(nameof(TaxAmount), value);
    }
    public ulong Channel
    {
        get => GetFieldValue<ulong>(nameof(Channel));
        set => SetFieldValue(nameof(Channel), value);
    }
    public NoYes? IsTaxIncludedInPrice
    {
        get => GetFieldValue<NoYes>(nameof(IsTaxIncludedInPrice));
        set => SetFieldValue(nameof(IsTaxIncludedInPrice), value);
    }
    public decimal? SalesLineNumber
    {
        get => GetFieldValue<decimal>(nameof(SalesLineNumber));
        set => SetFieldValue(nameof(SalesLineNumber), value);
    }
    public string TaxCode
    {
        get => GetFieldValue<string>(nameof(TaxCode));
        set => SetFieldValue(nameof(TaxCode), value);
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
    public decimal? TaxPercentage
    {
        get => GetFieldValue<decimal>(nameof(TaxPercentage));
        set => SetFieldValue(nameof(TaxPercentage), value);
    }
    public NoYes? IsExempt
    {
        get => GetFieldValue<NoYes>(nameof(IsExempt));
        set => SetFieldValue(nameof(IsExempt), value);
    }
}