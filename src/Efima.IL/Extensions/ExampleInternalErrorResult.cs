namespace Efima.IL.Extensions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;

[DefaultStatusCode(DefaultStatusCode)]
public class exmInternalErrorResult : ObjectResult
{
    private const int DefaultStatusCode = StatusCodes.Status500InternalServerError;

    public exmInternalErrorResult(string text)
        : base(text)
    {
        Text = text;
        StatusCode = DefaultStatusCode;
    }

    public string Text { get; set; }
}
