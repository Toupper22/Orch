using System;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Newtonsoft.Json;
using Efima.IL.Extensions;
using Efima.IL.Utils;

namespace Efima.IL;

public static class FunctionTriggerBase
{
	public static async Task<HttpResponseMessage> Exec<T1, T2>(
		HttpRequestMessage httpRequestMessage,
		Func<T1, Task<T2>> delegaFunc)
	{
		try
		{
			var requestJson = await httpRequestMessage.ReadContentAsJson<T1>();
			var result = await delegaFunc(requestJson);

			// until new serializer is not implemented
			//return httpRequestMessage.CreateResponse(result);
			return result is HttpResponseMessage responseMessage
				? responseMessage
				: new HttpResponseMessage(HttpStatusCode.OK)
				{
					Content = new StringContent(
							JsonConvert.SerializeObject(result),
							System.Text.Encoding.UTF8,
							"application/json")
				};
		}
		catch (Exception ex)
		{
			return ExceptionUtils.CreateResponse(ex, HttpStatusCode.BadRequest);
		}
	}
}

public class FunctionTriggerBase<TRequest, TResponse>
{
	protected readonly IDataTransformService<TRequest, TResponse> dataTransformService;

	protected FunctionTriggerBase(IDataTransformService<TRequest, TResponse> dataTransformService)
	{
		this.dataTransformService = dataTransformService;
	}

	public async Task<HttpResponseMessage> ExecuteTransformService(HttpRequestMessage httpRequestMessage, ExecutionContext context)
	{
		try
		{
			var requestJson = await httpRequestMessage.ReadContentAsJson<TRequest>();
			var result = await dataTransformService.Transform(requestJson);
			// until new serializer is not implemented
			//return httpRequestMessage.CreateResponse(result);
			if (result is HttpContent)
			{
				return new HttpResponseMessage(HttpStatusCode.OK)
				{
					Content = result as HttpContent
				};
			}
			return new HttpResponseMessage(HttpStatusCode.OK)
			{
				Content = new StringContent(
					JsonConvert.SerializeObject(result),
					System.Text.Encoding.UTF8,
					"application/json")
			};
		}
		catch (Exception ex)
		{
			return ExceptionUtils.CreateResponse(ex, HttpStatusCode.BadRequest);
		}
	}
}
