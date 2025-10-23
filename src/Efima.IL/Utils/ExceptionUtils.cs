namespace Efima.IL.Utils;

using Efima.Core.Shared.Utils.Serialization;
using Efima.IL.Extensions;

using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Simple.OData.Client;

using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text;
using System.Text.RegularExpressions;

public static class ExceptionUtils
{
    public static string FlattenExceptionMessage(string message)
    {
        return Regex.Replace(message.Replace(Environment.NewLine, " "),
            "(?:[^a-z0-9.,: ]|(?<=['\"])s)", string.Empty,
            RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);
    }

    public static string GetWebRequestExceptionDetails(WebRequestException ex, string separator)
    {
        var sb = new StringBuilder();
        sb.Append("WebRequestException details: ");

        sb.Append(separator);
        sb.AppendFormat($"Code: {ex.Code}");

        if (!string.IsNullOrEmpty(ex.ReasonPhrase))
        {
            sb.Append(separator);
            sb.AppendFormat($"Reason: {ex.ReasonPhrase}");
        }

        if (ex.RequestUri != null && !string.IsNullOrEmpty(ex.RequestUri.ToString()))
        {
            sb.Append(separator);
            sb.AppendFormat($"RequestUri: {ex.ReasonPhrase}");
        }

        if (!string.IsNullOrEmpty(ex.Response))
        {
            sb.Append(separator);
            sb.Append("Response: " + ex.Response.Replace(Environment.NewLine, " "));
        }

        return sb.ToString();
    }

    public static IActionResult NonRetryableException(Exception ex)
    {
        return new ContentResult
        {
            StatusCode = 400
            ,
            ContentType = "application/json"
            ,
            Content = JsonConvert.SerializeObject(ex)
        };

    }

    /// <summary>
    /// Create an informative result from the given exception and the root cause.
    /// </summary>
    public static ObjectResult CreateObjectResult(Exception ex,
                                                  HttpStatusCode defaultStatus = HttpStatusCode.BadRequest,
                                                  bool debug = true)
    {
        // Determine the root cause exception.
        Exception bex = ex.GetBaseException();
        bool hasInner = ex.InnerException != null;
        string exStr = (hasInner ? ex.GetType() + ", base exception: " : "") + bex.GetType();

        // Determine HTTP status.
        HttpStatusCode? httpStatus = null;
        switch (bex)
        {
            case Newtonsoft.Json.JsonException:
            case System.Text.Json.JsonException:
            case ArgumentException:
                httpStatus = HttpStatusCode.BadRequest;
                break;
            case SystemException:
                httpStatus = HttpStatusCode.InternalServerError;
                break;
            case HttpRequestException httpReqEx:
                httpStatus = httpReqEx.StatusCode;
                break;
        }
        if (!httpStatus.HasValue)
            httpStatus = defaultStatus;

        // Create a JSON-serializable content object.
        object jsonObject = debug ? new
        {
            Exception = exStr,
            bex.Message,
            Debug = string.Join(Environment.NewLine, ex.GetAllExceptionMessagesWithStackTrace())
        } : new
        {
            Exception = exStr,
            bex.Message
        };

        // Return result with the content.
        return new ObjectResult(jsonObject)
        {
            StatusCode = (int)httpStatus.Value
        };
    }

    /// <summary>
    /// Create an informative result from the given exception and the root cause.
    /// </summary>
    public static IActionResult CreateResult(Exception ex,
                                             HttpStatusCode defaultStatus = HttpStatusCode.BadRequest,
                                             bool debug = true)
    {
        // Determine the root cause exception.
        Exception bex = ex.GetBaseException();
        bool hasInner = ex.InnerException != null;
        string exStr = (hasInner ? ex.GetType() + ", base exception: " : "") + bex.GetType();

        // Determine HTTP status.
        HttpStatusCode? httpStatus = null;
        switch (bex)
        {
            case ArgumentException:
                httpStatus = HttpStatusCode.BadRequest;
                break;
            case SystemException:
                httpStatus = HttpStatusCode.InternalServerError;
                break;
            case HttpRequestException httpReqEx:
                httpStatus = httpReqEx.StatusCode;
                break;
        }
        if (!httpStatus.HasValue)
            httpStatus = defaultStatus;

        // Create a JSON-serializable content object.
        object jsonObject = debug ? new
        {
            Exception = exStr,
            bex.Message,
            Debug = string.Join(Environment.NewLine, ex.GetAllExceptionMessagesWithStackTrace())
        } : new
        {
            Exception = exStr,
            bex.Message
        };

        // Return result with the content.
        return new ContentResult
        {
            StatusCode = (int)httpStatus.Value,
            ContentType = "application/json",
            Content = jsonObject.SerializeToJson()
        };
    }

    /// <summary>
    /// Create an informative HTTP response from the given exception and the root cause.
    /// </summary>
    public static HttpResponseMessage CreateResponse(Exception ex,
                                                     HttpStatusCode defaultStatus = HttpStatusCode.BadRequest,
                                                     bool debug = true)
    {
        ObjectResult objectResult = CreateObjectResult(ex, defaultStatus, debug);
        return new HttpResponseMessage((HttpStatusCode)objectResult.StatusCode)
        {
            Content = JsonContent.Create(objectResult.Value)
        };
    }
}
