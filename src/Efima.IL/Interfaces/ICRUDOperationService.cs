using System.Threading.Tasks;

namespace Efima.IL.Interfaces;

public interface ICRUDOperationService<in TRequest, TResponse>
    where TRequest : class
    where TResponse : class
{
    Task<TResponse> ExecuteOperation(TRequest request);
}