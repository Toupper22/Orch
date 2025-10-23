using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;

namespace Efima.IL.Services.CRUD;

public class CRUDBaseOperationService
{
    protected readonly HttpClient _client;

    protected CRUDBaseOperationService(HttpClient httpClient)
    {
        _client = httpClient;
    }

    protected static async Task<HttpResponseMessage> SendAsync(Func<Task<HttpResponseMessage>> makeRequestFunc)
    {
        HttpResponseMessage response = null;

        try
        {
            response = await makeRequestFunc();
            response.EnsureSuccessStatusCode();
            return response;
        }
        catch (HttpRequestException)
        {
            var content = response is { Content: not null }
                ? await response.Content.ReadAsStringAsync()
                : "No content provided";

            return new HttpResponseMessage(HttpStatusCode.BadRequest)
            {
                Content = JsonContent.Create(new
                {
                    ApiCode = response.StatusCode,
                    ApiContent = content
                })
            };
        }
    }
}