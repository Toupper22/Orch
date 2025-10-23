using Efima.IL.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;

namespace Efima.IL.Utils;

public class ServiceBusUtils
{
	public static bool GetPrimitive(JsonElement jsonElement, out object value)
	{
		value = null;
		switch (jsonElement.ValueKind)
		{
			case JsonValueKind.String:
				value = jsonElement.GetString();
				break;
			case JsonValueKind.Number:
			{
				if (jsonElement.TryGetInt64(out long itgr))
					value = itgr;
				if (jsonElement.TryGetDouble(out double dbl))
					value = dbl;
				break;
			}
			case JsonValueKind.True:
			case JsonValueKind.False:
				value = jsonElement.GetBoolean();
				break;
		}
		return value != null;
	}

	public static DataEvent DeserializeDataEvent(JsonElement jsonElement, bool preImage = false)
	{
		if (!jsonElement.TryGetProperty("InputParameters", out jsonElement) ||
			jsonElement.ValueKind != JsonValueKind.Array)
		{
			throw new ArgumentException("Property 'InputParameters' missing or not array.");
		}

		var inputParameters = jsonElement.EnumerateArray();
		var result = new DataEventEntity();
		var changedFields = new List<string>();

		while (inputParameters.MoveNext())
		{
			var key = inputParameters.Current.GetProperty("key").GetString();
			if (key == "Target" || (preImage && key == "PreImage"))
			{
				JsonElement help, value = inputParameters.Current.GetProperty("value");
				var target = new DataEventEntityItem
				{
					Id = value.GetProperty("Id").GetString(),
					LogicalName = value.GetProperty("LogicalName").GetString(),
					Attributes = value.GetProperty("Attributes").EnumerateArray().Select(
						item => new DataEventEntityItemAttribute
						{
							key = item.GetProperty("key").GetString(),
							value = GetPrimitive(value = item.GetProperty("value"), out object primitive)
								? primitive
								: value.ValueKind == JsonValueKind.Object && value.TryGetProperty("Value", out help) && GetPrimitive(help, out primitive)
									? primitive
									: value.Clone()
						}).ToList()
				};

				if (key == "Target")
					result.Target = target;
				else
					result.PreImage = target;
			}
			if (key == "ChangedFields")
			{
				changedFields.AddRange(
					inputParameters.Current.GetProperty("value").EnumerateArray().Select(
						item => item.GetString()));
			}
		}

		result.ChangedFields = changedFields;
		return new DataEvent(result);
	}

	public static DataEvent DeserializeDataEvent(string json, string property = null, bool preImage = false)
	{
		using var jsonDocument = JsonDocument.Parse(json);
		var jsonElement = property == null
			? jsonDocument.RootElement
			: jsonDocument.RootElement.GetProperty(property);

		return DeserializeDataEvent(jsonElement, preImage);
	}

	public static ICollection<DataEvent> DeserializeDataEvents(string json, string arrayProperty = null, string eventProperty = null, bool preImage = false)
	{
		using var jsonDocument = JsonDocument.Parse(json);
		var jsonElement = arrayProperty == null
			? jsonDocument.RootElement
			: jsonDocument.RootElement.GetProperty(arrayProperty);

		if (jsonElement.ValueKind != JsonValueKind.Array)
		{
			throw new ArgumentException("Given JSON or property is not an array.");
		}

		var arrayItems = jsonElement.EnumerateArray();
		var result = new LinkedList<DataEvent>();

		while (arrayItems.MoveNext())
		{
			jsonElement = eventProperty == null
				? arrayItems.Current
				: arrayItems.Current.GetProperty(eventProperty);

			DataEvent dataEvent = DeserializeDataEvent(jsonElement, preImage);

			if (arrayItems.Current.TryGetProperty("SequenceNumber", out jsonElement))
			{
				dataEvent.SequenceNumber = jsonElement.GetUInt32();
			}
			result.AddLast(dataEvent);
		}

		return result;
	}
}
