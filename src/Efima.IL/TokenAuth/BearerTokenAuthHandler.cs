using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;

namespace Efima.IL.TokenAuth
{
    public class BearerTokenAuthHandler : DelegatingHandler
    {
        private ITokenProvider _authClient;

        public BearerTokenAuthHandler(ITokenProvider tokenProvider)
        {
            InnerHandler = new HttpClientHandler();
            _authClient = tokenProvider;
        }

        protected async override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            await AddBearerToken(request);

            return await base.SendAsync(request, cancellationToken);
        }

        protected async Task AddBearerToken(HttpRequestMessage message)
        {
            message.Headers.Authorization = new AuthenticationHeaderValue("Bearer", await _authClient.GetTokenAsync());
        }
    }
}
