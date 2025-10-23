using Efima.IL;
using Efima.Layer.D365F.GenericInterface.Core.Json.Model.Serialization.Newtonsoft;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

[assembly: FunctionsStartup(typeof(StartupBase))]


namespace Efima.IL;

public class StartupBase : FunctionsStartup
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        JsonConvert.DefaultSettings =
            () => new JsonSerializerSettings
            {
                TypeNameHandling = TypeNameHandling.None,
                DateParseHandling = DateParseHandling.None,
                Formatting = Formatting.Indented,
                NullValueHandling = NullValueHandling.Ignore,
                Converters = new JsonConverter[]
                {
                    new StringEnumConverter(),
                    new EntityConverter(),
                    new EntityFieldsCollectionConverter()
                }
            };
    }
}
