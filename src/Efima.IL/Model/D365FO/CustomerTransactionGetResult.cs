namespace Efima.IL.Model.D365FO;

using System.Collections.Generic;

public class CustomerTransactionGetResult
{
    public List<CustomerTransactionGetResponse> SearchResult { get; set; }
    public int RefTableId { get; set; }
}
