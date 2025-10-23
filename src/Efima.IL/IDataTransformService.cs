namespace Efima.IL;
using System.Threading.Tasks;

/// <summary>
/// Data transformation service
/// </summary>
/// <typeparam name="TRequest">input type</typeparam>
/// <typeparam name="TResponse">output type</typeparam>
public interface IDataTransformService<TRequest, TResponse>
{
    /// <summary>
    /// Runs transformation
    /// </summary>
    /// <param name="requestBodyString">request body as string, data with possible character escaping</param>
    /// <returns><c>TResult</c></returns>
    Task<TResponse> Transform(TRequest requestBodyJson);
}
