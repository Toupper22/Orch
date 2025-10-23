using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Security.Authentication;
using System.Threading;
using System.Threading.Tasks;
using Efima.IL.Utils;

namespace Efima.IL.TokenAuth;

public class ErpXOauthTokenService : ITokenProvider
{
    public static HttpClient Client { get; }

    protected SemaphoreSlim _tokenSemaphoreSlim;
    protected OauthTokenResponse _token;
    protected HttpClient httpClient;

    static ErpXOauthTokenService()
    {
        Client = new BearerTokenHttpClient(new ErpXOauthTokenService(), "Unit4ApiEndpoint");
    }

    protected ErpXOauthTokenService()
    {
        ValidateEnvironmentVariables();

        httpClient = new HttpClient()
        {
            Timeout = new TimeSpan(0, 9, 59),
            BaseAddress = new Uri(Environment.GetEnvironmentVariable("Unit4AccessTokenEndpoint"))
        };
        _tokenSemaphoreSlim = new SemaphoreSlim(1, 1);
    }

    private static void ValidateEnvironmentVariables()
    {
        HelperUtils.ValidateEnvironmentVariables(
            new List<string>()
            {
                "Unit4ApiEndpoint",
                "Unit4AccessTokenEndpoint",
                "Unit4ClientId",
                "Unit4ClientSecret",
                "Unit4Scope"
            });
    }

    public async Task<string> GetTokenAsync()
    {
        await _tokenSemaphoreSlim.WaitAsync();
        try
        {
            if (_token == null || _token.IsExpired)
            {
                _token = await GetNewAuthToken();
            }
        }
        catch (Exception)
        {
            throw;
        }
        finally
        {
            _tokenSemaphoreSlim.Release();
        }

        return _token.access_token;
    }

    protected async Task<OauthTokenResponse> GetNewAuthToken()
    {
        var result = await httpClient.PostAsync("", new FormUrlEncodedContent(
            new KeyValuePair<string, string>[]
            {
                new KeyValuePair<string, string>("grant_type", "client_credentials"),
                new KeyValuePair<string, string>("scope", Environment.GetEnvironmentVariable("Unit4Scope")),
                new KeyValuePair<string, string>("audience", Environment.GetEnvironmentVariable("Unit4ApiEndpoint")),
                new KeyValuePair<string, string>("client_id", Environment.GetEnvironmentVariable("Unit4ClientId")),
                new KeyValuePair<string, string>("client_secret", Environment.GetEnvironmentVariable("Unit4ClientSecret"))
            }
        ));

        if (!result.IsSuccessStatusCode)
        {
            throw new AuthenticationException(
                "Getting OAuth token failed.",
                new HttpRequestException(await result.Content.ReadAsStringAsync(), null, result.StatusCode));
        }

        return JsonConvert.DeserializeObject<OauthTokenResponse>(await result.Content.ReadAsStringAsync());
    }
}
