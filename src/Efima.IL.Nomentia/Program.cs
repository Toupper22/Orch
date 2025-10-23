using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Efima.Integration.Nomentia.Services;
using Efima.Integration.Nomentia.Values;
using Efima.IL;
using Efima.IL.Model;
using Efima.IL.Extensions;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices(services =>
    {
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();
        
        // Add value services
        services.AddValueServices(NomentiaBankStatementValues.Instance);

        // Add transform services
        services.AddSingleton<
            IDataTransformService<Base64FileTransformRequest, ExpenseJournalLineWithHeaderEntityResponse>,
            BankStatementTransformService>();

        services.AddSingleton<
            IDataTransformService<Base64FileTransformRequest, Base64FileResponse>,
            D365ArTransactionsTransformService>();
    })
    .Build();

host.Run();