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
[Entity("CustomerPaymentJournalHeaders",
    EntitySingularName = "CustomerPaymentJournalHeader",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent,
    IsCompanySpecific = true)]
[EntityPackage("Customer payment journal header.xml", targetEntityName: "CUSTOMERPAYMENTJOURNALHEADERENTITY")]
public class CustomerPaymentJournalHeaderEntity : Entity
{
    public override IList<EntityFieldsCollection> EntityUniqueKeys
    {
        get
        {
            var keysCollections = new List<EntityFieldsCollection>
            {
                ConstructKeysCollection(EntityField.dataAreaId_FieldAlias, nameof(JournalBatchNumber), nameof(JournalName))
            };
            return keysCollections;
        }
    }

    /// <summary> Field JournalBatchNumber on entity </summary>
    public string JournalBatchNumber
    {
        get => GetFieldValue<string>("JournalBatchNumber");
        set => SetFieldValue("JournalBatchNumber", value);
    }

    /// <summary> Field JournalName on entity </summary>
    public string JournalName
    {
        get => GetFieldValue<string>("JournalName");
        set => SetFieldValue("JournalName", value);
    }

    /// <summary> Field Description on entity </summary>
    public string Description
    {
        get => GetFieldValue<string>("Description");
        set => SetFieldValue("Description", value);
    }

    /// <summary> Field IsPosted on entity </summary>
    public NoYes IsPosted
    {
        get => GetFieldValue<NoYes>("IsPosted");
        set => SetFieldValue("IsPosted", value);
    }

    /// <summary> Field EfiCusLinkId on entity </summary>
    public override string EfiLinkId
    {
        get => GetFieldValue<string>("EfiCusLinkId");
        set => SetFieldValue("EfiCusLinkId", value);
    }
}
