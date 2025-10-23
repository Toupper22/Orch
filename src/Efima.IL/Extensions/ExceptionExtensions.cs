namespace Efima.IL.Extensions;

using Utils;

using Simple.OData.Client;

using System;
using System.Text;
using System.Collections.Generic;

public static class ExceptionExtensions
{
    public static string ExpandException(this Exception ex, string separator, bool includeStackTrace = false)
    {
        var sb = new StringBuilder();
        sb.Append(ex.Message);

        if (ex is WebRequestException webRequestException)
        {
            sb.Append(separator + ExceptionUtils.GetWebRequestExceptionDetails(webRequestException, separator));
        }

        if (includeStackTrace && !string.IsNullOrEmpty(ex.StackTrace))
        {
            sb.Append(separator + "Stack trace: " + ex.StackTrace);
        }

        if (ex.InnerException != null)
        {
            if (includeStackTrace)
            {
                sb.Append(separator);
            }

            sb.Append(separator + ex.InnerException.ExpandException(separator, includeStackTrace));
        }
        return sb.ToString();
    }

    public static IEnumerable<Exception> GetAllExceptions(this Exception ex)
    {
        var currentEx = ex;
        yield return currentEx;
        while (currentEx.InnerException != null)
        {
            currentEx = currentEx.InnerException;
            yield return currentEx;
        }
    }

    public static IEnumerable<string> GetAllExceptionAsString(this Exception ex)
    {
        var currentEx = ex;
        yield return currentEx.ToString();
        while (currentEx.InnerException != null)
        {
            currentEx = currentEx.InnerException;
            yield return currentEx.ToString();
        }
    }

    public static IEnumerable<string> GetAllExceptionMessages(this Exception ex)
    {
        var currentEx = ex;
        yield return currentEx.Message;
        while (currentEx.InnerException != null)
        {
            currentEx = currentEx.InnerException;
            yield return currentEx.Message;
        }
    }
    public static IEnumerable<string> GetAllExceptionMessagesWithStackTrace(this Exception ex)
    {
        var currentEx = ex;
        yield return currentEx.Message + Environment.NewLine + currentEx.StackTrace; ;
        while (currentEx.InnerException != null)
        {
            currentEx = currentEx.InnerException;
            yield return currentEx.Message + Environment.NewLine + currentEx.StackTrace;
        }
    }
}
