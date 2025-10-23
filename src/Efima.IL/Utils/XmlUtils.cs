namespace Efima.IL.Utils;
using System.IO;
using System.Xml.Serialization;
using System.Xml;

public class XmlUtils
{
    public static T Deserialize<T>(string serialized, bool namespaces = false) where T : class
    {
        T result;
        using (var textReader = new StringReader(serialized))
        {
            using var reader = new XmlTextReader(textReader);
            reader.Namespaces = namespaces;
            var serializer = new XmlSerializer(typeof(T));
            result = (T)serializer.Deserialize(reader);
        }

        return result;
    }

    public static XmlElement SerializeToXmlElement(object o)
    {
        XmlDocument doc = new();

        using (var writer = doc.CreateNavigator().AppendChild())
        {
            new XmlSerializer(o.GetType()).Serialize(writer, o);
        }

        return (XmlElement)doc.DocumentElement.Clone();
    }
}
