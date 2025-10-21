using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace MessageTransformer;

public class TransformMessage
{
    private readonly ILogger<TransformMessage> _logger;

    public TransformMessage(ILogger<TransformMessage> logger)
    {
        _logger = logger;
    }

    [Function("TransformMessage")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
    {
        _logger.LogInformation("TransformMessage function triggered");

        try
        {
            // Read the incoming message
            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();

            if (string.IsNullOrEmpty(requestBody))
            {
                return await CreateErrorResponse(req, "Empty request body", HttpStatusCode.BadRequest);
            }

            _logger.LogInformation("Received message: {Message}", requestBody);

            // Parse the incoming JSON
            var inputMessage = JsonSerializer.Deserialize<InputMessage>(requestBody);

            if (inputMessage == null)
            {
                return await CreateErrorResponse(req, "Invalid JSON format", HttpStatusCode.BadRequest);
            }

            // Transform the message
            var transformedMessage = new TransformedMessage
            {
                Id = Guid.NewGuid().ToString(),
                OriginalId = inputMessage.Id,
                ProcessedAt = DateTime.UtcNow,
                Data = new TransformedData
                {
                    CustomerName = inputMessage.CustomerName?.ToUpper() ?? "UNKNOWN",
                    OrderNumber = inputMessage.OrderNumber,
                    Amount = inputMessage.Amount,
                    Currency = inputMessage.Currency ?? "EUR",
                    Items = inputMessage.Items?.Select(item => new TransformedItem
                    {
                        ProductCode = item.ProductId,
                        Description = item.Description,
                        Quantity = item.Quantity,
                        UnitPrice = item.Price,
                        TotalPrice = item.Quantity * item.Price
                    }).ToList() ?? new List<TransformedItem>(),
                    TotalItems = inputMessage.Items?.Count ?? 0,
                    TotalQuantity = inputMessage.Items?.Sum(i => i.Quantity) ?? 0
                },
                Metadata = new MessageMetadata
                {
                    Source = "ServiceBus",
                    TransformedBy = "MessageTransformer",
                    Version = "1.0"
                }
            };

            _logger.LogInformation("Message transformed successfully: {TransformedId}", transformedMessage.Id);

            // Return the transformed message
            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(transformedMessage);
            return response;
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "JSON parsing error");
            return await CreateErrorResponse(req, $"JSON parsing error: {ex.Message}", HttpStatusCode.BadRequest);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error transforming message");
            return await CreateErrorResponse(req, $"Internal error: {ex.Message}", HttpStatusCode.InternalServerError);
        }
    }

    private async Task<HttpResponseData> CreateErrorResponse(HttpRequestData req, string message, HttpStatusCode statusCode)
    {
        var response = req.CreateResponse(statusCode);
        await response.WriteAsJsonAsync(new
        {
            error = message,
            timestamp = DateTime.UtcNow
        });
        return response;
    }
}

// Input message models
public class InputMessage
{
    public string? Id { get; set; }
    public string? CustomerName { get; set; }
    public string? OrderNumber { get; set; }
    public decimal Amount { get; set; }
    public string? Currency { get; set; }
    public List<InputItem>? Items { get; set; }
}

public class InputItem
{
    public string? ProductId { get; set; }
    public string? Description { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
}

// Output message models
public class TransformedMessage
{
    public string? Id { get; set; }
    public string? OriginalId { get; set; }
    public DateTime ProcessedAt { get; set; }
    public TransformedData? Data { get; set; }
    public MessageMetadata? Metadata { get; set; }
}

public class TransformedData
{
    public string? CustomerName { get; set; }
    public string? OrderNumber { get; set; }
    public decimal Amount { get; set; }
    public string? Currency { get; set; }
    public List<TransformedItem>? Items { get; set; }
    public int TotalItems { get; set; }
    public int TotalQuantity { get; set; }
}

public class TransformedItem
{
    public string? ProductCode { get; set; }
    public string? Description { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice { get; set; }
}

public class MessageMetadata
{
    public string? Source { get; set; }
    public string? TransformedBy { get; set; }
    public string? Version { get; set; }
}
