namespace Efima.IL.Model.D365FO;

public class ServiceBusPutRequest
{
    public string ConnectionString { get; set; }
    public string QueueName { get; set; }
    public string Label { get; set; }
    public string Message { get; set; }
}
