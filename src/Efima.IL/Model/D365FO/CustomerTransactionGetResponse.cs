using Efima.IL.Extensions.D365FO.Model;

namespace Efima.IL.Model.D365FO;
public class CustomerTransactionGetResponse
{
    public EfiCusCustomerTransactionsEntity TransactionEntity { get; set; }
    public string ErrorMessage { get; set; }
}
