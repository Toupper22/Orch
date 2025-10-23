using System;
using System.Net.Http;

namespace Efima.IL.TokenAuth;

public class BearerTokenHttpClient : HttpClient
{
    public BearerTokenHttpClient(ITokenProvider tokenService, string EndpointUrlVariable = "ApiEndpoint")
        : base(new BearerTokenAuthHandler(tokenService))
    {
        Timeout = new TimeSpan(0, 9, 59);
        BaseAddress = new Uri(Environment.GetEnvironmentVariable(EndpointUrlVariable));
    }
}
