namespace Efima.IL.Extensions.D365FO.Model;

using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;
using Efima.Layer.D365F.GenericInterface.Core.Model.Collections;

using System.Collections.Generic;

/// <summary>
/// Proxy class for MainAccounts entity
/// </summary>
[Entity("ConsolidateAccountGroups",
    EntitySingularName = "ConsolidateAccountGroup",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent,
    IsCompanySpecific = false)]
public class ConsolidateAccountGroupsEntity : Entity
{
    public override IList<EntityFieldsCollection> EntityUniqueKeys
    {
        get
        {
            var keysCollections = new List<EntityFieldsCollection>
            {
                ConstructKeysCollection("ConsolidationAccountGroup", "ChartOfAccounts", "MainAccountId")
            };
            return keysCollections;
        }
    }

    /// <summary> Field ConsolidationAccountGroup on entity </summary>
    public string ConsolidationAccountGroup
    {
        get => GetFieldValue<string>("ConsolidationAccountGroup");
        set => SetFieldValue("ConsolidationAccountGroup", value);
    }

    /// <summary> Field ChartOfAccounts on entity </summary>
    public string ChartOfAccounts
    {
        get => GetFieldValue<string>("ChartOfAccounts");
        set => SetFieldValue("ChartOfAccounts", value);
    }

    /// <summary> Field MainAccount on entity </summary>
    public string MainAccount
    {
        get => GetFieldValue<string>("MainAccount");
        set => SetFieldValue("MainAccount", value);
    }

    /// <summary> Field MainAccountName on entity </summary>
    public string MainAccountName
    {
        get => GetFieldValue<string>("MainAccountName");
        set => SetFieldValue("MainAccountName", value);
    }

    /// <summary> Field ConsolidationAccount on entity </summary>
    public string ConsolidationAccount
    {
        get => GetFieldValue<string>("ConsolidationAccount");
        set => SetFieldValue("ConsolidationAccount", value);
    }

    /// <summary> Field ConsolidationAccountGroupName on entity </summary>
    public string ConsolidationAccountGroupName
    {
        get => GetFieldValue<string>("ConsolidationAccountGroupName");
        set => SetFieldValue("ConsolidationAccountGroupName", value);
    }

    /// <summary> Field ConsolidationAccountName on entity </summary>
    public string ConsolidationAccountName
    {
        get => GetFieldValue<string>("ConsolidationAccountName");
        set => SetFieldValue("ConsolidationAccountName", value);
    }

}
