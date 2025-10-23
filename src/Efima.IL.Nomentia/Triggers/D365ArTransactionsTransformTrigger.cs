using System.Net.Http;
using System.Threading.Tasks;
using Efima.IL;
using Efima.IL.Model;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;

namespace Efima.Integration.Nomentia.Triggers;

public class D365ArTransactionsTransformTrigger
	: FunctionTriggerBase<Base64FileTransformRequest, Base64FileResponse>
{
	public D365ArTransactionsTransformTrigger(
		IDataTransformService<Base64FileTransformRequest, Base64FileResponse> dataTransformService)
		: base(dataTransformService)
	{
	}

	[Singleton, FunctionName(nameof(D365ArTransactionsTransform))]
	public async Task<HttpResponseMessage> D365ArTransactionsTransform(
		[HttpTrigger(AuthorizationLevel.Function, "post", Route = null)]
		HttpRequestMessage request,
		ExecutionContext context)
	{
		return await ExecuteTransformService(request, context);
	}
}
