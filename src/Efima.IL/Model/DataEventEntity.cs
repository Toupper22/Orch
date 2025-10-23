using System.Collections.Generic;
using System.Collections.ObjectModel;

namespace Efima.IL.Model;

public class DataEvent
{
	public DataEvent(DataEventEntity dataEventEntity)
	{
		DataEventEntityValue = dataEventEntity;
	}

	public DataEventEntity DataEventEntityValue { get; }

	public uint SequenceNumber { get; set; }
}

public class DataEventEntity
{
	public DataEventEntityItem Target { get; set; }

	public DataEventEntityItem PreImage { get; set; }

	public ICollection<string> ChangedFields { get; set; }
}

public class DataEventEntityItem
{
	public string LogicalName { get; set; }

	public string Id { get; set; }

	public ICollection<DataEventEntityItemAttribute> Attributes { get; set; }
}

public sealed class DataEventEntityItemAttribute
{
	public string key { get; set; }

	public object value { get; set; }
}
