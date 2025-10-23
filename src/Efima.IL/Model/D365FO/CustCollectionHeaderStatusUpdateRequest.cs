namespace Efima.IL.Model.D365FO;
using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;
using Efima.Layer.D365F.GenericInterface.OData.Common.Enums;

using System;
using System.Collections.Generic;

public class CustCollectionHeaderStatusUpdateRequest
{
    public CustCollectionHeaderStatusUpdateRequest()
    {
        Entities = new List<EfiCustCollectionHeaderEntity>();
    }

    public ICollection<EfiCustCollectionHeaderEntity> Entities { get; set; }
    public EfiCustCollectionStatus NewStatus { get; set; }
    public string BatchNumber { get; set; }
    public DateTime? DateTimeCreated { get; set; }
}
