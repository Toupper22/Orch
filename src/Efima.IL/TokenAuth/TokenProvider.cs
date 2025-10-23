using System.Threading.Tasks;

namespace Efima.IL.TokenAuth
{
    public interface ITokenProvider
    {
        public Task<string> GetTokenAsync();
    }
}
