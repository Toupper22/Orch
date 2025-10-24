using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;

namespace SepaTransformer;

public class TransformSepaFile
{
    private readonly ILogger<TransformSepaFile> _logger;

    public TransformSepaFile(ILogger<TransformSepaFile> logger)
    {
        _logger = logger;
    }

    [Function("TransformSepaFile")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
    {
        _logger.LogInformation("SEPA file transformation function processing a request.");

        try
        {
            // Read the request body
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();

            if (string.IsNullOrEmpty(requestBody))
            {
                _logger.LogWarning("Empty request body received");
                var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                await badResponse.WriteAsJsonAsync(new TransformationResult
                {
                    Success = false,
                    ErrorMessage = "Request body cannot be empty"
                });
                return badResponse;
            }

            // Transform the payload by appending "transformed"
            string transformedPayload = requestBody + "transformed";

            _logger.LogInformation("SEPA file transformed successfully. Original length: {OriginalLength}, Transformed length: {TransformedLength}",
                requestBody.Length, transformedPayload.Length);

            // Create success response
            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(new TransformationResult
            {
                Success = true,
                OriginalPayload = requestBody,
                TransformedPayload = transformedPayload,
                TransformationTimestamp = DateTime.UtcNow
            });

            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error transforming SEPA file");

            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteAsJsonAsync(new TransformationResult
            {
                Success = false,
                ErrorMessage = ex.Message
            });

            return errorResponse;
        }
    }
}

public class TransformationResult
{
    public bool Success { get; set; }
    public string? OriginalPayload { get; set; }
    public string? TransformedPayload { get; set; }
    public DateTime? TransformationTimestamp { get; set; }
    public string? ErrorMessage { get; set; }
}
