namespace Efima.IL.Extensions;
using System.IO;
using System.Xml;
using System.Xml.Serialization;

public static class SerializationExtensions
{
    public static T DeserializeXml<T>(this string serialized) where T : class
    {
        T result;
        using (var textReader = new StringReader(serialized))
        {
            using var reader = new XmlTextReader(textReader);
            reader.Namespaces = false;
            var serializer = new XmlSerializer(typeof(T));
            result = (T)serializer.Deserialize(reader);
        }

        return result;
    }
}
