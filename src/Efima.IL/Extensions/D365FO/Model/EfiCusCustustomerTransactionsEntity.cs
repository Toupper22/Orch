namespace Efima.IL.Extensions.D365FO.Model;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;
using Efima.Layer.D365F.GenericInterface.Core.Model.Collections;

using System;
using System.Collections.Generic;

/// <summary>
/// Proxy class for EfiCusCustomerTransactions entity
/// </summary>
[Entity("EfiCusCustomerTransactions",
    EntitySingularName = "EfiCusCustomerTransaction",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
public class EfiCusCustomerTransactionsEntity : Entity
{

    public override IList<EntityFieldsCollection> EntityUniqueKeys
    {
        get
        {
            var keysCollections = new List<EntityFieldsCollection>
            {
                ConstructKeysCollection(EntityField.dataAreaId_FieldAlias, EntityField.RecId_FieldAlias)
            };
            return keysCollections;
        }
    }

    /// <summary> Field AccountNum on entity </summary>
    public string CustomerAccount
    {
        get => GetFieldValue<string>("AccountNum");
        set => SetFieldValue("AccountNum", value);
    }
    /// <summary> Field DocumentDate on entity </summary>
    public DateTime DocumentDate
    {
        get => GetFieldValue<DateTime>("DocumentDate");
        set => SetFieldValue("DocumentDate", value);
    }
    /// <summary> Field DocumentNum on entity </summary>
    public string DocumentNum
    {
        get => GetFieldValue<string>("DocumentNum");
        set => SetFieldValue("DocumentNum", value);
    }
    /// <summary> Field DueDate on entity </summary>
    public DateTime DueDate
    {
        get => GetFieldValue<DateTime>("DueDate");
        set => SetFieldValue("DueDate", value);
    }
    /// <summary> Field Invoice on entity </summary>
    public string Invoice
    {
        get => GetFieldValue<string>("Invoice");
        set => SetFieldValue("Invoice", value);
    }
    /// <summary> Field MCRPaymOrderID on entity </summary>
    public string MCRPaymOrderID
    {
        get => GetFieldValue<string>("MCRPaymOrderID");
        set => SetFieldValue("MCRPaymOrderID", value);
    }
    /// <summary> Field OrderAccount on entity </summary>
    public string OrderAccount
    {
        get => GetFieldValue<string>("OrderAccount");
        set => SetFieldValue("OrderAccount", value);
    }
    /// <summary> Field PaymId on entity </summary>
    public string PaymId
    {
        get => GetFieldValue<string>("PaymId");
        set => SetFieldValue("PaymId", value);
    }
    /// <summary> Field PaymMethod on entity </summary>
    public string PaymMethod
    {
        get => GetFieldValue<string>("PaymMethod");
        set => SetFieldValue("PaymMethod", value);
    }
    /// <summary> Field PaymMode on entity </summary>
    public string PaymMode
    {
        get => GetFieldValue<string>("PaymMode");
        set => SetFieldValue("PaymMode", value);
    }
    /// <summary> Field PaymReference on entity </summary>
    public string PaymReference
    {
        get => GetFieldValue<string>("PaymReference");
        set => SetFieldValue("PaymReference", value);
    }
    /// <summary> Field PaymSpec on entity </summary>
    public string PaymSpec
    {
        get => GetFieldValue<string>("PaymSpec");
        set => SetFieldValue("PaymSpec", value);
    }
    /// <summary> Field PaymTermId on entity </summary>
    public string PaymTermId
    {
        get => GetFieldValue<string>("PaymTermId");
        set => SetFieldValue("PaymTermId", value);
    }
    /// <summary> Field TransDate on entity </summary>
    public DateTime TransDate
    {
        get => GetFieldValue<DateTime>("TransDate");
        set => SetFieldValue("TransDate", value);
    }
    /// <summary> Field TransType on entity </summary>
    //TODO enum
    public string TransType
    {
        get => GetFieldValue<string>("TransType");
        set => SetFieldValue("TransType", value);
    }
    /// <summary> Field Txt on entity </summary>
    public string Txt
    {
        get => GetFieldValue<string>("Txt");
        set => SetFieldValue("Txt", value);
    }
    /// <summary> Field Voucher on entity </summary>
    public string Voucher
    {
        get => GetFieldValue<string>("Voucher");
        set => SetFieldValue("Voucher", value);
    }
    /// <summary> Field ThirdPartyBankAccountId on entity </summary>
    public string ThirdPartyBankAccountId
    {
        get => GetFieldValue<string>("ThirdPartyBankAccountId");
        set => SetFieldValue("ThirdPartyBankAccountId", value);
    }
    /// <summary> Field CollectionLetterCode on entity </summary>
    public string CollectionLetterCode
    {
        get => GetFieldValue<string>("CollectionLetterCode");
        set => SetFieldValue("CollectionLetterCode", value);
    }
}
