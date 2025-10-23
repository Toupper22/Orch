using Efima.IL;
using Efima.IL.Extensions;
using Efima.IL.Model;
using Efima.Integration.Nomentia;
using Efima.Integration.Nomentia.Models;
using Efima.Integration.Nomentia.Services;
using Efima.Integration.Nomentia.Values;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(Startup))]

namespace Efima.Integration.Nomentia;

public class Startup : StartupBase
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        base.Configure(builder);

        builder.Services.AddValueServices(NomentiaBankStatementValues.Instance);

        builder.Services.AddSingleton<
            IDataTransformService<Base64FileTransformRequest, ExpenseJournalLineWithHeaderEntityResponse>,
                BankStatementTransformService>();

        builder.Services.AddSingleton<
            IDataTransformService<Base64FileTransformRequest, Base64FileResponse>,
                D365ArTransactionsTransformService>();
    }
}