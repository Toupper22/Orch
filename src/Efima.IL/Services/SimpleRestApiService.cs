using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;

namespace Efima.IL.Services;

public class SimpleRestApiService : ISimpleRestApiService
{
    private readonly HttpClient httpClient;

    public string DefaultQuery { get; set; }

    public SimpleRestApiService(HttpClient httpClient)
    {
        this.httpClient = httpClient;
    }

    /// <summary>
    /// </summary>
    public async Task<HttpResponseMessage> SimpleGet(HttpRequestMessage request)
    {
        // Get target URL.
        string url = GetApiUrl(request);

        // Make GET request to the REST API.
        HttpResponseMessage apiResp = await httpClient.GetAsync(url);

        HandleErrorResp(url, apiResp);

        // Reuse the response content but clear headers other than content type & length.
        return new HttpResponseMessage(apiResp.StatusCode)
        {
            Content = ClearOtherThanContentHeaders(apiResp.Content)
        };
    }

    /// <summary>
    /// </summary>
    public async Task<HttpResponseMessage> SimplePost(HttpRequestMessage request, HttpMethod method = null)
    {
        // Get target URL.
        string url = GetApiUrl(request);

        // Reuse the request content but clear headers other than content type & length.
        HttpContent httpContent = ClearOtherThanContentHeaders(request.Content);

        // Make POST, PUT, or PATCH request to the REST API.
        HttpResponseMessage apiResp;
        if (method == null || method == HttpMethod.Post)
        {
            apiResp = await httpClient.PostAsync(url, httpContent);
        }
        else if (method == HttpMethod.Put)
        {
            apiResp = await httpClient.PutAsync(url, httpContent);
        }
        else if (method == HttpMethod.Patch)
        {
            apiResp = await httpClient.PatchAsync(url, httpContent);
        }
        else
        {
            throw new NotImplementedException("Unsupported HttpMethod: " + method);
        }

        HandleErrorResp(url, apiResp);

        var response = new HttpResponseMessage(apiResp.StatusCode);

        // Reuse API response content but clear headers other than content type & length.
        if (apiResp.Content.Headers.ContentLength != 0)
        {
            response.Content = ClearOtherThanContentHeaders(apiResp.Content);
        }
        // Also forward Location since it's essential when present (e.g. 201, 202).
        if (apiResp.Headers.Contains("Location"))
        {
            IEnumerable<string> locationValues = apiResp.Headers.GetValues("Location");
            response.Headers.Add("Location", locationValues);
        }

        return response;
    }

    private static string GetQueryParam(HttpRequestMessage request, string paramName)
    {
        return HttpUtility.ParseQueryString(request.RequestUri.Query)[paramName];
    }

    private static HttpContent ClearOtherThanContentHeaders(HttpContent httpContent)
    {
        var contentType = httpContent.Headers.ContentType;
        var contentLength = httpContent.Headers.ContentLength;

        httpContent.Headers.Clear();

        httpContent.Headers.ContentType = contentType;
        httpContent.Headers.ContentLength = contentLength;

        return httpContent;
    }

    private string GetApiUrl(HttpRequestMessage request)
    {
        // Get API path from a query param.
        string apiPath = GetQueryParam(request, nameof(apiPath));

        if (DefaultQuery == null)
            return apiPath;

        // Append either ? or & plus the default query.
        string path = (string.IsNullOrEmpty(apiPath) ? "?" : apiPath + (apiPath.Contains('?') ? "&" : "?"));

        return path + DefaultQuery;
    }

    private static async void HandleErrorResp(string url, HttpResponseMessage response)
    {
        if (!response.IsSuccessStatusCode)
        {
            string bodyStr = await response.Content?.ReadAsStringAsync();
            throw new HttpRequestException($"Call to '{url}' failed.",
                new HttpRequestException(bodyStr, null, response.StatusCode),
                HttpStatusCode.BadGateway);
        }
    }
}