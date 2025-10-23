using System.Net.Http;
using System.Threading.Tasks;
using Efima.IL.Interfaces;
using Efima.IL.Model.CRUD;

namespace Efima.IL.Services.CRUD;

public class CRUDGetOperationService : CRUDBaseOperationService,
    ICRUDOperationService<CRUDGetOperationRequest, HttpResponseMessage>
{
    public CRUDGetOperationService(HttpClient httpClient) : base(httpClient)
    {
    }

    public async Task<HttpResponseMessage> ExecuteOperation(CRUDGetOperationRequest request)
    {
        return await SendAsync(() => _client.GetAsync(request.RequestUri));
    }
}