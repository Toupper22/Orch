using System.Net.Http;
using System.Threading.Tasks;
using Efima.IL.Interfaces;
using Efima.IL.Model.CRUD;

namespace Efima.IL.Services.CRUD;

public class CRUDPostOperationService : CRUDBaseOperationService,
    ICRUDOperationService<CRUDPostOperationRequest, HttpResponseMessage>
{
    public CRUDPostOperationService(HttpClient httpClient) : base(httpClient)
    {
    }

    public async Task<HttpResponseMessage> ExecuteOperation(CRUDPostOperationRequest request)
    {
        return await SendAsync(() => _client.PostAsJsonAsync(request.RequestUri, request.JsonPayload));
    }
}