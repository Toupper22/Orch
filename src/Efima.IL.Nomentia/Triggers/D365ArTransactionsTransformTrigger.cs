using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Efima.IL;
using Efima.IL.Model;

namespace Efima.Integration.Nomentia.Triggers;

public class D365ArTransactionsTransformTrigger
{
	private readonly ILogger<D365ArTransactionsTransformTrigger> _logger;
	private readonly IDataTransformService<Base64FileTransformRequest, Base64FileResponse> _dataTransformService;

	public D365ArTransactionsTransformTrigger(
		ILogger<D365ArTransactionsTransformTrigger> logger,
		IDataTransformService<Base64FileTransformRequest, Base64FileResponse> dataTransformService)
	{
		_logger = logger;
		_dataTransformService = dataTransformService;
	}

	[Function("D365ArTransactionsTransform")]
	public async Task<HttpResponseData> D365ArTransactionsTransform(
		[HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
	{
		_logger.LogInformation("D365ArTransactionsTransform function triggered.");

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
			_logger.LogError(ex, "Error processing D365 AR transactions transform");
			
			var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
			await errorResponse.WriteStringAsync($"Error: {ex.Message}");
			return errorResponse;
		}
	}
}
