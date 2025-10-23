using System.Collections.Generic;
using DurableTask.Core.Common;
using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;

namespace Efima.IL.Model;

public class CollectionResponse<T>
{
	public CollectionResponse(ICollection<T> entities)
	{
		EntityCollection = entities;
	}

	public ICollection<T> EntityCollection { get; set; }
}