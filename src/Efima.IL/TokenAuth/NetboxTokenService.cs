using Newtonsoft.Json;
using System;
using System.Text;
using System.Net.Http;
using System.Security.Authentication;
using System.Threading;
using System.Threading.Tasks;
using Efima.IL.Utils;

using static System.Environment;
using static System.Text.Encoding;
using static System.Security.Cryptography.SHA1;
using System.Collections.Generic;

namespace Efima.IL.TokenAuth
{
    public class NetboxTokenService : ITokenProvider
    {
        public static HttpClient Client { get; }

        protected SemaphoreSlim _tokenSemaphoreSlim;
        protected OauthTokenResponse _token;
        protected HttpClient httpClient;

        static NetboxTokenService()
        {
            Client = new BearerTokenHttpClient(new NetboxTokenService(), "NetboxApiEndpoint");
        }

        protected NetboxTokenService()
        {
            ValidateEnvironmentVariables();

            httpClient = new HttpClient()
            {
                Timeout = new TimeSpan(0, 9, 59),
                BaseAddress = new Uri(GetEnvironmentVariable("NetboxAccessTokenEndpoint"))
            };
            _tokenSemaphoreSlim = new SemaphoreSlim(1, 1);
        }

        public static void ValidateEnvironmentVariables()
        {
            HelperUtils.ValidateEnvironmentVariables(
                new List<string>()
                {
                    "NetboxApiEndpoint",
                    "NetboxAccessTokenEndpoint",
                    "NetboxCustomerId",
                    "NetboxUsername",
                    "NetboxPassword"
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
            // Request a ticket.
            HttpResponseMessage result = await httpClient.GetAsync(string.Format("tickets/{0}/{1}",
                GetEnvironmentVariable("NetboxUsername"),
                GetEnvironmentVariable("NetboxCustomerId")
            ));
            string body = await result.Content.ReadAsStringAsync();

            if (!result.IsSuccessStatusCode)
            {
                throw new AuthenticationException(
                    "Getting authentication ticket failed. URL: " + result.RequestMessage.RequestUri,
                    new HttpRequestException(body, null, result.StatusCode));
            }

            // Parse the ticket from response.
            var ticketResp = JsonConvert.DeserializeObject<NetboxTicketResponse>(body);
            if (string.IsNullOrWhiteSpace(ticketResp.ticket) || ticketResp.ticket.Length < 10)
            {
                throw new AuthenticationException(
                    "Invalid authentication ticket: " + ticketResp.ticket);
            }

            // Compute an SHA1 hash from the ticket + password.
            byte[] bytes = HashData(UTF8.GetBytes(
                GetEnvironmentVariable("NetboxPassword") + ticketResp.ticket));

            // Print as hex.
            StringBuilder stringBuilder = new StringBuilder(bytes.Length * 2);
            foreach (byte bt in bytes)
            {
                stringBuilder.AppendFormat("{0:x2}", bt);
            }

            // Request a token.
            result = await httpClient.GetAsync(string.Format("tokens/{0}", stringBuilder));
            body = await result.Content.ReadAsStringAsync();

            if (!result.IsSuccessStatusCode)
            {
                throw new AuthenticationException(
                    "Getting authentication token failed. Ticket: " + ticketResp.ticket + ", URL: " + result.RequestMessage.RequestUri,
                    new HttpRequestException(body, null, result.StatusCode));
            }

            // Parse the token from response.
            var tokenResp = JsonConvert.DeserializeObject<NetboxTokenResponse>(body);
            if (string.IsNullOrWhiteSpace(tokenResp.token))
            {
                throw new AuthenticationException(
                    "Got empty authentication token.");
            }

            return new OauthTokenResponse()
            {
                access_token = tokenResp.token
            };
        }
    }
}
