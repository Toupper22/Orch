using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Efima.IL;
using Efima.IL.Model;

namespace Efima.Integration.Nomentia.Triggers;

public class BankStatementTransformTrigger
{
	private readonly ILogger<BankStatementTransformTrigger> _logger;
	private readonly IDataTransformService<Base64FileTransformRequest, ExpenseJournalLineWithHeaderEntityResponse> _dataTransformService;

	public BankStatementTransformTrigger(
		ILogger<BankStatementTransformTrigger> logger,
		IDataTransformService<Base64FileTransformRequest, ExpenseJournalLineWithHeaderEntityResponse> dataTransformService)
	{
		_logger = logger;
		_dataTransformService = dataTransformService;
	}

	[Function("BankStatementTransform")]
	public async Task<HttpResponseData> BankStatementTransform(
		[HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
	{
		_logger.LogInformation("BankStatementTransform function triggered.");

		try
		{
			// Read the request body
			var requestBody = await req.ReadAsStringAsync();
			if (string.IsNullOrEmpty(requestBody))
			{
				var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
				await badResponse.WriteStringAsync("Request body is empty");
				return badResponse;
			}

			var request = JsonSerializer.Deserialize<Base64FileTransformRequest>(requestBody);

			if (request == null)
			{
				var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
				await badResponse.WriteStringAsync("Invalid request body");
				return badResponse;
			}

			// Transform the data
			var result = await _dataTransformService.Transform(request);

			// Create successful response
			var response = req.CreateResponse(HttpStatusCode.OK);
			response.Headers.Add("Content-Type", "application/json");
			
			var jsonResult = JsonSerializer.Serialize(result);
			await response.WriteStringAsync(jsonResult);
			
			return response;
		}
		catch (Exception ex)
		{
			_logger.LogError(ex, "Error processing bank statement transform");
			
			var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
			await errorResponse.WriteStringAsync($"Error: {ex.Message}");
			return errorResponse;
		}
	}
}
