namespace Efima.IL.Extensions.D365FO.Model;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;
using Efima.Layer.D365F.GenericInterface.Core.Model.Collections;

using System;
using System.Collections.Generic;

/// <summary>
/// Proxy class for MainAccountLegalEntities entity
/// </summary>
[Entity("MainAccountLegalEntities",
    EntitySingularName = "MainAccountLegalEntity",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
public class MainAccountLegalEntitiesEntity : Entity
{
    public override IList<EntityFieldsCollection> EntityUniqueKeys
    {
        get
        {
            var keysCollections = new List<EntityFieldsCollection>
            {
                ConstructKeysCollection("MainAccountId", "ChartOfAccounts", "LegalEntityId")
            };
            return keysCollections;
        }
    }

    /// <summary> Field ChartOfAccounts on entity </summary>
    public string ChartOfAccounts
    {
        get => GetFieldValue<string>("ChartOfAccounts");
        set => SetFieldValue("ChartOfAccounts", value);
    }

    /// <summary> Field MainAccountId on entity </summary>
    public string MainAccountId
    {
        get => GetFieldValue<string>("MainAccountId");
        set => SetFieldValue("MainAccountId", value);
    }

    /// <summary> Field LegalEntityId on entity </summary>
    public string LegalEntityId
    {
        get => GetFieldValue<string>("LegalEntityId");
        set => SetFieldValue("LegalEntityId", value);
    }

    /// <summary> Field ActiveFrom on entity </summary>
    public DateTime ActiveFrom
    {
        get => GetFieldValue<DateTime>("ActiveFrom");
        set => SetFieldValue("ActiveFrom", value);
    }

    /// <summary> Field ActiveTo on entity </summary>
    public DateTime ActiveTo
    {
        get => GetFieldValue<DateTime>("ActiveTo");
        set => SetFieldValue("ActiveTo", value);
    }

    /// <summary> Field IsSuspended on entity </summary>
    public NoYes IsSuspended
    {
        get => GetFieldValue<NoYes>("IsSuspended");
        set => SetFieldValue("IsSuspended", value);
    }

    /// <summary> Field ValidateSalesTax on entity </summary>
    public string ValidateSalesTax
    {
        get => GetFieldValue<string>("ValidateSalesTax");
        set => SetFieldValue("ValidateSalesTax", value);
    }

}
