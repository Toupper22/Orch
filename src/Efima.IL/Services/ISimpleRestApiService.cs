using System.Net.Http;
using System.Threading.Tasks;

namespace Efima.IL.Services;

public interface ISimpleRestApiService
{
    string DefaultQuery { get; set; }

    Task<HttpResponseMessage> SimpleGet(HttpRequestMessage request);

    Task<HttpResponseMessage> SimplePost(HttpRequestMessage request, HttpMethod method = null);
}