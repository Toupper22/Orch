namespace Efima.IL.Extensions.D365FO.Model;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;
using Efima.Layer.D365F.GenericInterface.Core.Model.Collections;
using System.Collections.Generic;

/// <summary>
/// Proxy class for MainAccounts entity
/// </summary>
[Entity("CustomerPaymentJournalFees",
    EntitySingularName = "CustomerPaymentJournalFee",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent,
    IsCompanySpecific = true)]
[EntityPackage("Customer payment journal fee.xml", targetEntityName: "CUSTOMERPAYMENTJOURNALFEEENTITY")]
public class CustomerPaymentJournalFeeEntity : Entity
{
    public override IList<EntityFieldsCollection> EntityUniqueKeys
    {
        get
        {
            var keysCollections = new List<EntityFieldsCollection>
            {
                ConstructKeysCollection(EntityField.dataAreaId_FieldAlias, nameof(SourceJournalBatchNumber), nameof(SourceJournalLineNumber))
            };
            return keysCollections;
        }
    }
    /// <summary> Field SourceJournalBatchNumber on entity </summary>
    public string SourceJournalBatchNumber
    {
        get => GetFieldValue<string>("SourceJournalBatchNumber");
        set => SetFieldValue("SourceJournalBatchNumber", value);
    }
    /// <summary> Field SourceJournalLineNumber on entity </summary>
    public decimal SourceJournalLineNumber
    {
        get => GetFieldValue<decimal>("SourceJournalLineNumber");
        set => SetFieldValue("SourceJournalLineNumber", value);
    }
    /// <summary> Field PaymentFeeId on entity </summary>
    public string PaymentFeeId
    {
        get => GetFieldValue<string>("PaymentFeeId");
        set => SetFieldValue("PaymentFeeId", value);
    }
    /// <summary> Field DefaultDimensionDisplayValue on entity </summary>
    public string DefaultDimensionDisplayValue
    {
        get => GetFieldValue<string>("DefaultDimensionDisplayValue");
        set => SetFieldValue("DefaultDimensionDisplayValue", value);
    }
    /// <summary> Field IsWithholdingCalculationEnabled on entity </summary>
    public NoYes IsWithholdingCalculationEnabled
    {
        get => GetFieldValue<NoYes>("IsWithholdingCalculationEnabled");
        set => SetFieldValue("IsWithholdingCalculationEnabled", value);
    }
    /// <summary> Field CurrencyCode on entity </summary>
    public string CurrencyCode
    {
        get => GetFieldValue<string>("CurrencyCode");
        set => SetFieldValue("CurrencyCode", value);
    }
    /// <summary> Field AccountType on entity </summary>
    public string AccountType
    {
        get => GetFieldValue<string>("AccountType");
        set => SetFieldValue("AccountType", value);
    }
    /// <summary> Field ItemSalesTaxGroup on entity </summary>
    public string ItemSalesTaxGroup
    {
        get => GetFieldValue<string>("ItemSalesTaxGroup");
        set => SetFieldValue("ItemSalesTaxGroup", value);
    }
    /// <summary> Field Amount on entity </summary>
    public decimal Amount
    {
        get => GetFieldValue<decimal>("Amount");
        set => SetFieldValue("Amount", value);
    }
    /// <summary> Field SalesTaxDirection on entity </summary>
    public string SalesTaxDirection
    {
        get => GetFieldValue<string>("SalesTaxDirection");
        set => SetFieldValue("SalesTaxDirection", value);
    }
    /// <summary> Field ItemWithholdingTaxGroupCode on entity </summary>
    public string ItemWithholdingTaxGroupCode
    {
        get => GetFieldValue<string>("ItemWithholdingTaxGroupCode");
        set => SetFieldValue("ItemWithholdingTaxGroupCode", value);
    }
    /// <summary> Field SalesTaxGroup on entity </summary>
    public string SalesTaxGroup
    {
        get => GetFieldValue<string>("SalesTaxGroup");
        set => SetFieldValue("SalesTaxGroup", value);
    }
    /// <summary> Field AccountDisplayValue on entity </summary>
    public string AccountDisplayValue
    {
        get => GetFieldValue<string>("AccountDisplayValue");
        set => SetFieldValue("AccountDisplayValue", value);
    }
    /// <summary> Field EfiCusLinkId on entity </summary>
    public override string EfiLinkId
    {
        get => GetFieldValue<string>("EfiCusLinkId");
        set => SetFieldValue("EfiCusLinkId", value);
    }
    /// <summary> Field EfiCusLinkIdParent on entity </summary>
    public override string EfiLinkIdParent
    {
        get => GetFieldValue<string>("EfiCusLinkIdParent");
        set => SetFieldValue("EfiCusLinkIdParent", value);
    }
}
