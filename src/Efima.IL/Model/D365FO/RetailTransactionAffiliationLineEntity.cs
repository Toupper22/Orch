using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactionAffiliationLines entity
/// </summary>
[Entity("RetailTransactionAffiliationLines", EntitySingularName = "RetailTransactionAffiliationLine",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Affiliations for transactions.xml", "", "", "RetailTransactionAffiliationLineEntity")]
public class RetailTransactionAffiliationLineEntity : Entity
{
    public string ReceiptNumber
    {
        get => GetFieldValue<string>(nameof(ReceiptNumber));
        set => SetFieldValue(nameof(ReceiptNumber), value);
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
    public string AffiliationName
    {
        get => GetFieldValue<string>(nameof(AffiliationName));
        set => SetFieldValue(nameof(AffiliationName), value);
    }
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
}
