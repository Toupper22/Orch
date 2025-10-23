using System.Net.Http;
using System.Threading.Tasks;
using Efima.IL;
using Efima.IL.Model;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;

namespace Efima.Integration.Nomentia.Triggers;

public class BankStatementTransformTrigger
	: FunctionTriggerBase<Base64FileTransformRequest, ExpenseJournalLineWithHeaderEntityResponse>
{
	public BankStatementTransformTrigger(
		IDataTransformService<Base64FileTransformRequest, ExpenseJournalLineWithHeaderEntityResponse> dataTransformService)
		: base(dataTransformService)
	{
	}

	[Singleton, FunctionName(nameof(BankStatementTransform))]
	public async Task<HttpResponseMessage> BankStatementTransform(
		[HttpTrigger(AuthorizationLevel.Function, "post", Route = null)]
		HttpRequestMessage request,
		ExecutionContext context)
	{
		return await ExecuteTransformService(request, context);
	}
}
