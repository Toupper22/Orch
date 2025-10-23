using System;

namespace Efima.IL.TokenAuth
{
    public class OauthTokenResponse
    {
        //TODO No time to implement "retry on expired token" logic to HttpClient, just decrease the token lifetime by some seconds for now 
        private readonly static int _expiryOffset = 15;
        private readonly DateTime _createdDt;

        public bool IsExpired
        {
            get
            {
                return _createdDt.AddSeconds(expires_in - _expiryOffset) <= DateTime.UtcNow;
            }
        }

        public OauthTokenResponse()
        {
            _createdDt = DateTime.UtcNow;
        }

        public string access_token { get; set; }
        public int expires_in { get; set; }
        public string token_type { get; set; }
        public string scope { get; set; }
    }

}
