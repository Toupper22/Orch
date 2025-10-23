using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;

using System.Collections.Generic;

namespace Efima.IL.Model.D365FO;

public class ExpenseJournalODataRequest
{
    public EfiExpenseJournalHeaderEntity ExpenseJournalHeaderEntity { get; set; }

    public ICollection<EfiExpenseJournalLineWithHeaderEntity> EfiExpenseJournalLineWithHeaderEntities { get; set; } = [];
}
