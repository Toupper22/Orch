using System.Collections.Generic;
using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;

namespace Efima.IL.Model;

public class ExpenseJournalLineWithHeaderEntityResponse
{
	public ExpenseJournalLineWithHeaderEntityResponse(ICollection<EfiExpenseJournalLineWithHeaderEntity> entities)
	{
		EfiExpenseJournalLineWithHeaderEntities = entities;
	}

	public ICollection<EfiExpenseJournalLineWithHeaderEntity> EfiExpenseJournalLineWithHeaderEntities { get; set; }
}