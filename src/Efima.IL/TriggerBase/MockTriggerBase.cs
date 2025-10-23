namespace Efima.IL.TriggerBase;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

using System;
using System.Threading.Tasks;

public class MockTriggerBase
{
    public async Task<IActionResult> Execute(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
        ILogger log,
        ITransformationService _service)
    {
        try
        {
            return await _service.Run(req.Body);
        }
        catch (Exception e)
        {
            log.LogError(e, $"{e}");
            return new ContentResult
            {
                StatusCode = 500,
                Content = $"{e.Message}"
            };
        }
    }
}
