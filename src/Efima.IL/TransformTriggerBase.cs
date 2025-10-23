using System;
using System.Net;
using System.Net.Http;
using System.Reflection;
using System.Threading.Tasks;
using Efima.IL.Extensions;
using Efima.IL.Utils;
using Microsoft.Azure.WebJobs;
using Newtonsoft.Json;

namespace Efima.IL;

public class TransformTriggerBase<TRequest, TResponse> where TRequest : class
{
    protected readonly IDataTransformService<TRequest, TResponse> dataTransformService;

    public TransformTriggerBase(IDataTransformService<TRequest, TResponse> dataTransformService)
    {
        this.dataTransformService = dataTransformService;
    }

    public async Task<HttpResponseMessage> InvokeConstructorAndExecuteServiceOperation(HttpRequestMessage httpRequest,
        ExecutionContext context = null)
    {
        try
        {
            var strCtor = typeof(TRequest).GetConstructor([typeof(string)]);
            if (strCtor == null)
            {
                throw new NotImplementedException("No public constructor with one string argument found for " + typeof(TRequest));
            }
            string body = await httpRequest.Content.ReadAsStringAsync();
            TRequest requestObject = strCtor.Invoke([body]) as TRequest;
            TResponse result = await dataTransformService.Transform(requestObject);
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

    public async Task<HttpResponseMessage> ExecuteServiceOperation(HttpRequestMessage httpRequest,
        ExecutionContext context = null,
        JsonSerializerSettings requestJsonSerializerSettings = null,
        JsonSerializerSettings responseJsonSerializerSettings = null,
        bool emptyAsNoContent = false)
    {
        try
        {
            dynamic requestObject = typeof(TRequest) == typeof(HttpRequestMessage)
                ? httpRequest
                : await httpRequest.ReadContentAsJson<TRequest>(requestJsonSerializerSettings);

            TResponse result = await dataTransformService.Transform(requestObject);

            string body = JsonConvert.SerializeObject(result, responseJsonSerializerSettings);
            return emptyAsNoContent && (body == "{}" || body == "[]")
				? new HttpResponseMessage(HttpStatusCode.NoContent)
                : new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(body,
                        System.Text.Encoding.UTF8,
                        "application/json")
                };
        }
        catch (Exception ex)
        {
            return ExceptionUtils.CreateResponse(ex, HttpStatusCode.BadRequest);
        }
    }

    public Task<HttpResponseMessage> ExecuteServiceOperationEmptyAsNoContent(HttpRequestMessage httpRequest,
        ExecutionContext context = null,
        JsonSerializerSettings requestJsonSerializerSettings = null)
    {
        JsonSerializerSettings respJsonSerializerSettings = new()
        {
            NullValueHandling = NullValueHandling.Ignore
        };
        return ExecuteServiceOperation(httpRequest, context, requestJsonSerializerSettings, respJsonSerializerSettings, true);
    }
}