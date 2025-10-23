using System;

namespace Efima.IL.TokenAuth
{
    public class NetboxTokenResponse
    {
        public string version { get; set; }

        public string token { get; set; }

        public string expires { get; set; }
    }
}
